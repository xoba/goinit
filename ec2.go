// launches process in ec2 to package a particular
// version of go. needs aws cli installed
package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"text/template"
	"time"
)

type S3Uri string

func (s S3Uri) Bucket() string {
	u, err := url.Parse(string(s))
	check(err)
	return u.Host
}

func (s S3Uri) Key() string {
	u, err := url.Parse(string(s))
	check(err)
	if len(u.Path) > 0 {
		return u.Path[1:]
	}
	return u.Path
}

func (s S3Uri) Url() string {
	return fmt.Sprintf("https://s3.amazonaws.com/%s/%s", s.Bucket(), s.Key())
}

func getInstanceId(o object) string {
	instances := o["Instances"].([]interface{})[0].(map[string]interface{})
	return instances["InstanceId"].(string)
}

func main() {
	var s3gz, s3log, latest, profile, commit, genbucket string
	var terminate, dryrun bool
	var ngen int
	flag.StringVar(&s3gz, "s3gz", "", "s3 url to store distribution")
	flag.StringVar(&s3log, "s3log", "", "s3 url to store log")
	flag.StringVar(&profile, "profile", "", "aws cli profile to use")
	flag.StringVar(&commit, "commit", "master", "git branch or commit to build")
	flag.BoolVar(&terminate, "terminate", true, "whether to terminate instance afterwards")
	flag.BoolVar(&dryrun, "dryrun", false, "don't launch any machines")
	flag.StringVar(&latest, "latest", "", "populate a 'latest' file on s3")
	flag.StringVar(&genbucket, "gen", "", "generate candidate command lines with given bucket")
	flag.IntVar(&ngen, "n", 1, "number of candidates to generate")
	flag.Parse()

	auth, err := LoadProfile(profile)
	check(err)
	if len(genbucket) > 0 {
		gen(profile, genbucket, ngen)
		return
	}
	const driver = "ec2-driver.sh"
	f, err := os.Create(driver)
	check(err)
	t, err := template.ParseFiles("ec2-template.sh")
	check(err)
	check(t.Execute(f, map[string]interface{}{
		"comment":   fmt.Sprintf("go language commit %s, built %v, for linux", commit, time.Now().UTC()),
		"commit":    commit,
		"s3gz":      s3gz,
		"latest":    latest,
		"s3gzurl":   S3Uri(s3gz).Url(),
		"s3gzkey":   S3Uri(s3gz).Key(),
		"s3log":     s3log,
		"accessKey": auth.AccessKey,
		"secretKey": auth.SecretKey,
		"terminate": terminate,
	}))
	f.Close()
	if !dryrun {
		r, err := AwsCli("ec2", "--profile", profile, "run-instances", "--image-id", "ami-ee793a86", "--instance-type", "m3.xlarge", "--key-name", "golang_rsa", "--user-data", "file://"+driver)
		check(err)
		fmt.Println(r)
		if len(latest) > 0 {
			fmt.Printf("check %s for install script\n", S3Uri(latest).Url())
		}

		dt := time.Hour
		fmt.Printf("going to terminate instance %q in %v\n", getInstanceId(r), dt)
		time.Sleep(time.Hour)
		r2, err := AwsCli("ec2", "--profile", profile, "terminate-instances", "--instance-ids", getInstanceId(r))
		check(err)
		fmt.Println(r2)
	}
}

func gen(profile, bucket string, n int) {

	t := template.Must(template.New("nodes.gv").Parse(`./ec2 -latest s3://{{.bucket}}/install.sh -profile {{.profile}} -commit {{.commit}} -s3gz s3://{{.bucket}}/{{.time}}_{{.commit}}.tar.gz -s3log s3://{{.bucket}}/log_{{.time}}_{{.commit}}.txt # {{.comment}}
`))
	for i, c := range getLogs("go") {
		if i == n {
			break
		}
		check(t.Execute(os.Stdout, map[string]interface{}{
			"profile": profile,
			"commit":  c.Hash[:12],
			"bucket":  bucket,
			"time":    c.CommitterTime.Format("20060102T150405Z"),
			"comment": c.Comment,
		}))
	}
}

type Commit struct {
	Hash          string
	Author        string
	Comment       string
	AuthorTime    time.Time
	CommitterTime time.Time
}

type Commits []Commit

func (c Commits) Len() int {
	return len(c)
}

func (c Commits) Less(i, j int) bool {
	return c[i].CommitterTime.Before(c[j].CommitterTime)
}

func (c Commits) Swap(i, j int) {
	c[i], c[j] = c[j], c[i]
}

func getLogs(dir string) (out Commits) {
	atimes := getLogField(dir, "%at")
	ctimes := getLogField(dir, "%ct")
	authors := getLogField(dir, "%an")
	comments := getLogField(dir, "%s")
	for h, t := range ctimes {
		c := Commit{
			Hash:          h,
			Author:        authors[h],
			Comment:       comments[h],
			AuthorTime:    gitTime(atimes[h]),
			CommitterTime: gitTime(t),
		}
		out = append(out, c)
	}
	sort.Sort(sort.Reverse(out))
	return
}

func gitTime(s string) time.Time {
	f := strings.Fields(s)
	u, err := strconv.ParseInt(f[0], 10, 64)
	check(err)
	return time.Unix(u, 0).UTC()
}

func getLogField(dir string, pretty string) map[string]string {
	out := make(map[string]string)
	buf := new(bytes.Buffer)
	cmd := exec.Command(`git`, `log`, `--pretty=%H `+pretty)
	cmd.Dir = dir
	cmd.Stdout = buf
	check(cmd.Run())
	s := bufio.NewScanner(buf)
	for s.Scan() {
		line := s.Text()
		i := strings.Index(line, " ")
		hash := line[:i]
		field := line[i+1:]
		out[hash] = field
	}
	check(s.Err())
	return out
}

type object map[string]interface{}

func (o object) String() string {
	buf, err := json.Marshal(o)
	check(err)
	return string(buf)
}

func AwsCli(args ...string) (object, error) {
	{
		var hasProfile bool
		for _, a := range args {
			if a == "--profile" {
				hasProfile = true
			}
		}
		if !hasProfile {
			return nil, fmt.Errorf("oops, no profile!")
		}
	}
	buf := new(bytes.Buffer)
	cmd := exec.Command("/usr/bin/aws", args...)
	cmd.Stdout = buf
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return nil, err
	}
	m := make(map[string]interface{})
	d := json.NewDecoder(buf)
	if err := d.Decode(&m); err != nil {
		return nil, err
	}
	return m, nil
}

type AwsAuth struct {
	AccessKey string
	SecretKey string
}

func LoadProfile(p string) (*AwsAuth, error) {
	out := &AwsAuth{}
	clean := func(s string) string {
		return strings.TrimSpace(strings.ToLower(s))
	}
	u, err := user.Current()
	if err != nil {
		return nil, err
	}
	config := filepath.Join(u.HomeDir, ".aws/config")
	f, err := os.Open(config)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	var active bool
	s := bufio.NewScanner(f)
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		if len(line) == 0 {
			continue
		}
		if strings.HasPrefix(line, "[") {
			if line == "["+p+"]" || line == "[profile "+p+"]" {
				active = true
			} else {
				active = false
			}
		} else if active {
			parts := strings.Split(line, "=")
			key := clean(parts[0])
			value := strings.TrimSpace(parts[1])
			switch key {
			case "aws_secret_access_key":
				out.SecretKey = value
			case "aws_access_key_id":
				out.AccessKey = value
			}
		}
	}
	if err := s.Err(); err != nil {
		return nil, err
	}
	if len(out.SecretKey) == 0 || len(out.AccessKey) == 0 {
		return nil, fmt.Errorf("no profile %q found", p)
	}
	return out, nil
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

// launches process in ec2 to package a particular
// version of go. needs aws cli installed
package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
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

func main() {
	var profile, commit, s3gz, candidates, s3log string
	var terminate, dryrun bool
	flag.StringVar(&s3gz, "s3gz", "", "s3 url to store distribution")
	flag.StringVar(&s3log, "s3log", "", "s3 url to store log")
	flag.StringVar(&profile, "profile", "", "aws cli profile to use")
	flag.StringVar(&commit, "commit", "master", "git branch or commit to build")
	flag.BoolVar(&terminate, "terminate", true, "whether to terminate instance afterwards")
	flag.BoolVar(&dryrun, "dryrun", false, "don't launch any machines")
	flag.StringVar(&candidates, "gen", "", "generate candidate command lines with given bucket")
	flag.Parse()
	auth, err := LoadProfile(profile)
	check(err)
	if len(candidates) > 0 {
		gen(profile, candidates)
		return
	}
	const driver = "ec2-driver.sh"
	f, err := os.Create(driver)
	check(err)
	t, err := template.ParseFiles("ec2-template.sh")
	check(err)
	check(t.Execute(f, map[string]interface{}{
		"commit":    commit,
		"s3gz":      s3gz,
		"s3log":     s3log,
		"accessKey": auth.AccessKey,
		"secretKey": auth.SecretKey,
		"terminate": terminate,
	}))
	f.Close()
	if !dryrun {
		AwsCli("ec2", "run-instances", "--image-id", "ami-ee793a86", "--instance-type", "m3.xlarge", "--key-name", "golang_rsa", "--user-data", "file://"+driver)
	}
}

func gen(profile, bucket string) {

	t := template.Must(template.New("nodes.gv").Parse(`go run ec2.go -profile {{.profile}} -commit {{.commit}} -s3gz s3://{{.bucket}}/go_{{.commit}}.tar.gz -s3log s3://{{.bucket}}/log_{{.commit}}.txt # {{.date}} {{.comment}}
`))
	for i, c := range getLogs("go") {
		if i > 30 {
			break
		}
		check(t.Execute(os.Stdout, map[string]interface{}{
			"profile": profile,
			"commit":  c.Hash[:10],
			"bucket":  bucket,
			"date":    c.CommitterTime,
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
	return time.Unix(u, 0)
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

func AwsCli(args ...string) error {
	cmd := exec.Command("aws", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
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
		line := s.Text()
		if strings.HasPrefix(line, "[") {
			if line == "["+p+"]" {
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

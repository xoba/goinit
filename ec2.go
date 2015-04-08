// launches process in ec2 to package a particular
// version of go. needs aws cli installed
package main

import (
	"bufio"
	"flag"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"text/template"
)

func main() {
	var profile, commit, s3gz, s3log string
	var terminate, dryrun bool
	flag.StringVar(&s3gz, "s3gz", "", "s3 url to store distribution")
	flag.StringVar(&s3log, "s3log", "", "s3 url to store log")
	flag.StringVar(&profile, "profile", "", "aws cli profile to use")
	flag.StringVar(&commit, "commit", "8ac129e5304c6d16b4562c3f13437765d7c8a184", "golang commit to build")
	flag.BoolVar(&terminate, "terminate", true, "whether to terminate instance afterwards")
	flag.BoolVar(&dryrun, "dryrun", false, "don't launch any machines")
	flag.Parse()
	auth := LoadProfile(profile)
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

func LoadProfile(p string) *AwsAuth {
	out := &AwsAuth{}
	clean := func(s string) string {
		return strings.TrimSpace(strings.ToLower(s))
	}
	u, err := user.Current()
	check(err)
	config := filepath.Join(u.HomeDir, ".aws/config")
	f, err := os.Open(config)
	check(err)
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
	check(s.Err())
	return out
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

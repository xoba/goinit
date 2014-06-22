// creates a miniature version of go distribution for building from scratch
package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
)

const (
	source     = "go"
	target_dir = "target"
	target     = target_dir + "/" + source
)

func main() {
	check(FetchGo())
	check(CopyCriticalBits())
	check(SetupHg())
	check(PackageUp())
	fmt.Printf("run \"tar xf %s.tar.gz; cd %s/src; ./make.bash\"\n", source, source)
}

func FetchGo() error {
	_, err := os.Stat(source)
	if err != nil {
		cmd := exec.Command("hg", "clone", "https://code.google.com/p/go")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	}
	return nil
}

func CopyCriticalBits() error {
	filter := func(p string) bool {
		const prefixes = "src,include,misc"
		for _, x := range strings.Split(prefixes, ",") {
			if strings.HasPrefix(p, path.Clean(source+"/"+x)) {
				return true
			}
		}
		return false
	}

	return filepath.Walk(source, func(p string, info os.FileInfo, err error) (out error) {
		if err != nil {
			return err
		}
		if !filter(p) {
			return
		}
		rel := path.Clean(target + "/" + p[len(source):])
		if info.IsDir() {
			os.MkdirAll(rel, os.ModePerm)
			return
		}
		f, err := os.Create(rel)
		if err != nil {
			return err
		}
		g, err := os.Open(p)
		if err != nil {
			return err
		}
		defer g.Close()
		_, err = io.Copy(f, g)
		if err != nil {
			return err
		}
		if err := f.Close(); err != nil {
			return err
		}
		return os.Chmod(rel, info.Mode())
	})
}

func SetupHg() error {

	{
		cmd := exec.Command("hg", "init")
		cmd.Dir = target
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return err
		}
	}

	{
		f, err := os.Create(path.Clean(target + "/.hg/hgrc"))
		if err != nil {
			return err
		}
		fmt.Fprintln(f, "[ui]\nusername = John Doe <john@example.com>")
		f.Close()
	}

	{
		cmd := exec.Command("hg", "add", "make.bash")
		cmd.Dir = path.Clean(target + "/src")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return err
		}
	}

	{
		cmd := exec.Command("hg", "commit", "-m", "yadda yadda yadda")
		cmd.Dir = target
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return err
		}
	}
	return nil
}

func PackageUp() error {

	{
		cmd := exec.Command("tar", "cf", "../"+source+".tar", source)
		cmd.Dir = target_dir
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return err
		}
	}

	{
		cmd := exec.Command("gzip", source+".tar")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return err
		}
	}

	return nil

}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

// tries to get latest version and sha256 hashes from golang website
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"golang.org/x/mod/semver"
)

type Download struct {
	Version  string
	Platform string
	Arch     string
	Tar      string
	Href     string
	Sha256   string
}

func (d Download) String() string {
	buf, _ := json.Marshal(d)
	return string(buf)
}

var verbose bool

func init() {
	flag.BoolVar(&verbose, "v", true, "whether to be verbose or not")
	flag.Parse()
}

func main() {
	base, err := url.Parse("https://golang.org/dl/")
	check(err)
	doc, err := goquery.NewDocument(base.String())
	check(err)
	var downloads []*Download
	doc.Find("table.downloadtable tr").Each(func(i int, s *goquery.Selection) {
		var name, href, typ, os, arch, sha string
		s.Find("a").Each(func(i int, s *goquery.Selection) {
			v, ok := s.Attr("href")
			r, err := url.Parse(v)
			check(err)
			if ok {
				href = base.ResolveReference(r).String()
			}
		})
		s.Find("td").Each(func(i int, s *goquery.Selection) {
			text := s.Text()
			switch i {
			case 0:
				name = text
			case 1:
				typ = text
			case 2:
				os = text
			case 3:
				arch = text
			case 5:
				sha = text
			}
		})
		if typ != "Archive" {
			return
		}
		d := &Download{
			Tar:      name,
			Href:     href,
			Sha256:   sha,
			Platform: os,
			Arch:     arch,
		}
		p := regexp.MustCompile(`(go\d+\.\d+(\.\d+)?)\..+`)
		if p.MatchString(name) {
			v := p.FindStringSubmatch(name)[1]
			d.Version = "v" + v[2:]
			if !semver.IsValid(d.Version) {
				panic(d.Version)
			}
		}
		if d.Version != "" {
			downloads = append(downloads, d)
		}
	})
	sort.Slice(downloads, func(i, j int) bool {
		return semver.Compare(downloads[i].Version, downloads[j].Version) == +1
	})
	first := func(f func(*Download) bool) *Download {
		for _, d := range downloads {
			if f(d) {
				return d
			}
		}
		return nil
	}
	check(write("darwin_i386", first(func(d *Download) bool {
		return d.Platform == "macOS" && d.Arch == "x86-64"
	})))
	check(write("darwin_arm", first(func(d *Download) bool {
		return d.Platform == "macOS" && d.Arch == "ARM64"
	})))
	check(write("linux_x86_64", first(func(d *Download) bool {
		return d.Platform == "Linux" && d.Arch == "x86-64"
	})))
	return

	for _, d := range downloads {
		fmt.Println(d)
	}
}

func write(name string, value interface{}) error {
	switch t := value.(type) {
	case string:
		value := strings.TrimSpace(t)
		if verbose {
			fmt.Printf("%s = %q\n", name, value)
		}
		if err := os.MkdirAll("versions", os.ModePerm); err != nil {
			return err
		}
		return ioutil.WriteFile(filepath.Join("versions", name+".txt"), []byte(value+"\n"), os.ModePerm)
	case *Download:
		sub := func(k, v string) error {
			return write(name+"_"+k, v)
		}
		if err := sub("tar", t.Tar); err != nil {
			return err
		}
		if err := sub("href", t.Href); err != nil {
			return err
		}
		if err := sub("sha", t.Sha256); err != nil {
			return err
		}
		return nil
	default:
		return fmt.Errorf("can't handle %T", t)
	}
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

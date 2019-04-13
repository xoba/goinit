// tries to get latest version and sha256 hashes from golang website
package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

type Download struct {
	Tar    string
	Href   string
	Sha256 string
}

var verbose bool

func init() {
	flag.BoolVar(&verbose, "v", false, "whether to be verbose or not")
	flag.Parse()
}

func main() {
	doc, err := goquery.NewDocument("https://golang.org/dl/")
	check(err)
	var darwin, linux *Download
	var version string
	doc.Find("table.codetable tr").Each(func(i int, s *goquery.Selection) {
		var name, href, typ, os, arch, sha string
		s.Find("a").Each(func(i int, s *goquery.Selection) {
			v, ok := s.Attr("href")
			if ok {
				href = v
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
		if arch != "x86-64" {
			return
		}
		if version == "" {
			p := regexp.MustCompile(`(go\d+\.\d+\.\d+)\..+`)
			if p.MatchString(name) {
				version = p.FindStringSubmatch(name)[1]
			}
		}
		d := &Download{
			Tar:    name,
			Href:   href,
			Sha256: sha,
		}
		switch os {
		case "macOS":
			if darwin == nil {
				darwin = d
			}
		case "Linux":
			if linux == nil {
				linux = d
			}
		}
	})
	check(write("version", version))
	check(write("darwin", darwin))
	check(write("linux", linux))
}

func write(name string, value interface{}) error {
	switch t := value.(type) {
	case string:
		value := strings.TrimSpace(t)
		if verbose {
			fmt.Printf("%s = %q\n", name, value)
		}
		return ioutil.WriteFile(name+".txt", []byte(value+"\n"), os.ModePerm)
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

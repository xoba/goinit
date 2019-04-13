// tries to get latest version and sha256 hashes from golang website
package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

func main() {
	doc, err := goquery.NewDocument("https://golang.org/dl/")
	check(err)
	var darwin, linux, version string
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
		switch os {
		case "macOS":
			if darwin == "" {
				darwin = sha
			}
		case "Linux":
			if linux == "" {
				linux = sha
			}
		}
	})
	write("version", version)
	write("darwin", darwin)
	write("linux", linux)
}

func write(name, value string) error {
	value = strings.TrimSpace(value)
	fmt.Printf("%s = %q\n", name, value)
	return ioutil.WriteFile(name+".txt", []byte(value+"\n"), os.ModePerm)
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

package main

import (
	"flag"
	"os"
	"text/template"
)

func panicIfErr(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	version := flag.String("version", "1.5rc1", "Go version to generate a Dockerfile for")
	flag.Parse()

	tmpl, err := template.ParseFiles("./Dockerfile.tmpl")
	panicIfErr(err)

	f, err := os.Create("./Dockerfile")
	panicIfErr(err)
	defer f.Close()

	panicIfErr(tmpl.Execute(f, struct {
		Version string
	}{*version}))
}

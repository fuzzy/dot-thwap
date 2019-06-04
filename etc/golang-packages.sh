for i in fiximports:golang.org/x/tools/cmd/... \
             godef:github.com/rogpeppe/godef/... \
             gocode:github.com/nsf/gocode \
             goimports:golang.org/x/tools/cmd/goimports \
             guru:golang.org/x/tools/cmd/guru \
             goflymake:github.com/dougm/goflymake; do
    provides=$(echo ${i}|awk -F: '{print $1}')
    location=$(echo ${i}|awk -F: '{print $2}')
    test -z "${provides}" && echo ${location} && go get ${location}
done

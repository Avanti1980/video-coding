gitbook build
git add *
git commit -m "$1"
git push github master
git subtree push --prefix=_book github gh-pages
git push gitee master
git subtree push --prefix=_book gitee gh-pages
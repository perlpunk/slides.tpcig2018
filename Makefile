gh-pages:
	git worktree add gh-pages gh-pages

html-yamlpp:
	perl -I ../App-BBSlides-p5/lib ../App-BBSlides-p5/bin/bbslides \
	yamlpp/slides/yamlpp.yaml \
	--out gh-pages/yamlpp \
	--data yamlpp/data \
	--html-data yamlpp/html/data

html-status:
	cd gh-pages && git status

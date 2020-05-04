#!/bin/bash

if [[ -f .url ]]; then
    URL=$(cat .url)
fi
if [[ $URL == "" ]]; then
    URL=https://registry.hub.docker.com/v2/repositories/library/node/tags
fi

while [[ $URL != "" ]]; do
    echo $URL > .url

    exitCode=1
    while [[ $exitCode != 0 ]]; do
        content=$(curl -s $URL)
        exitCode=$?
        echo "$exitCode - $URL"
    done

    URL=$(
        echo $content | \
        grep -oE '"next":"https://registry.hub.docker.com/v2/[^"]+"' | \
        sed -e 's/^"next":"//' | \
        sed -e 's/"$//'
    )
    tags=$(
        echo $content | \
        grep -oE '"name":"[^"]+"' | \
        sed -e 's/^"name":"//' | \
        sed -e 's/"$//' | \
        grep -v 'alpine' | \
        grep -v 'onbuild' | \
        grep -v 'wheezy'
    )
    for tag in $tags; do
        exitCode=1
        while [[ $exitCode != 0 ]]; do
            content=$(curl -s https://registry.hub.docker.com/v2/repositories/library/node/tags/$tag)
            exitCode=$?
            echo "$exitCode - https://registry.hub.docker.com/v2/repositories/library/node/tags/$tag"
        done

        digestCurrent=$(
            echo $content | \
            grep -oE '"digest":"[^"]+"' | \
            sed -e 's/^"digest":"//' | \
            sed -e 's/"$//' && \
            echo dockerfile:`md5 -q Dockerfile.template`
        )
        digestOld=$(cat hashes/$tag 2> /dev/null)
        if [[ $digestCurrent != $digestOld ]] && [[ $digestCurrent != "" ]]; then
            docker pull node:$tag
            docker pull satantime/puppeteer-node:$tag
            echo "FROM node:${tag}" > Dockerfile && \
            cat Dockerfile.template >> Dockerfile && \
            docker build . -t satantime/puppeteer-node:$tag && \
            rm Dockerfile
            code="${?}"
            files=""
            if [[ -f hashes/$tag ]]; then
                git rm hashes/$tag
                files="$files hashes/$tag"
            fi
            if [[ -f hashes/$tag.error ]]; then
                git rm hashes/$tag.error
                files="$files hashes/$tag.error"
            fi
            if [[ "${code}" == "0" ]]; then
                printf '%s\n' $digestCurrent > hashes/$tag
                git add hashes/$tag
                files="$files hashes/$tag"
            fi
            if [[ "${code}" != "0" ]]; then
                printf '%s\n' $digestCurrent > hashes/$tag.error
                git add hashes/$tag.error
                files="$files hashes/$tag.error"
            fi

            if [[ "${code}" == "0" ]]; then
                (docker push satantime/puppeteer-node:$tag && \
                git commit -m "Update of $tag on $(date +%Y-%m-%d)" $files) &
            fi
            if [[ "${code}" != "0" ]]; then
                git commit -m "Error of $tag on $(date +%Y-%m-%d)" $files
            fi
        fi
        true;
    done
    true;
done
rm .url

#!/usr/bin/env bash
#---------------------------------------------------
ORG_NAME=leanprover
REPO_NAME=lean
GIT_REMOTE_REPO=git@github.com:${ORG_NAME}/${REPO_NAME}
PORT_NAME=lean
PORT_FILE=ports/lang/lean/Portfile
PORT_TEMPLATE=ports/lang/lean/Portfile.template
OSX_VERSION=`sw_vers -productVersion`
ARCHIVE_PATH=/opt/local/var/macports/software
#---------------------------------------------------
if [ ! -d ./${REPO_NAME} ] ; then
    git clone ${GIT_REMOTE_REPO}
fi   

cd ${REPO_NAME}
git rev-parse HEAD > PREVIOUS_HASH
git fetch --all --quiet
git reset --hard origin/master --quiet
git rev-parse HEAD > CURRENT_HASH
COMMIT_DATETIME=$(date -r `git show -s --format="%ct" HEAD` +"%Y%m%d%H%M%S")
cd ..

if ! cmp ${REPO_NAME}/PREVIOUS_HASH ${REPO_NAME}/CURRENT_HASH >/dev/null 2>&1
then
    DOIT=TRUE
fi
if [[ $1 == "-f" ]] ; then
    DOIT=TRUE
fi

if [[ $DOIT == TRUE ]] ; then
    echo "===================================="
    echo "1. Update port with a new version"
    echo "===================================="
    VERSION_MAJOR=`grep -o -i "VERSION_MAJOR \([0-9]\+\)" ${REPO_NAME}/src/CMakeLists.txt | cut -d ' ' -f 2`
    VERSION_MINOR=`grep -o -i "VERSION_MINOR \([0-9]\+\)" ${REPO_NAME}/src/CMakeLists.txt | cut -d ' ' -f 2`
    VERSION_PATCH=`grep -o -i "VERSION_PATCH \([0-9]\+\)" ${REPO_NAME}/src/CMakeLists.txt | cut -d ' ' -f 2`
    COMMIT_HASH=`cat ${REPO_NAME}/CURRENT_HASH`
    SOURCE_VERSION=${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
    VERSION_STRING=${SOURCE_VERSION}.${COMMIT_DATETIME}.${COMMIT_HASH}
    cp ${PORT_TEMPLATE} ${PORT_FILE}
    sed -i "" "s/##SOURCE_VERSION##/${SOURCE_VERSION}/g" ${PORT_FILE}
    sed -i "" "s/##COMMIT_HASH##/${COMMIT_HASH}/g" ${PORT_FILE}
    sed -i "" "s/##COMMIT_DATETIME##/${COMMIT_DATETIME}/g" ${PORT_FILE}
    echo "UPDATE PORT: ${VERSION_STRING}"


    echo "========================================"
    echo "2. Update master branch with new port"
    echo "========================================"
    cd ports && /opt/local/bin/portindex && cd ..
    sudo port -v sync
    sudo port upgrade ${PORT_NAME}
    sudo port uninstall inactive
    sudo port archive ${PORT_NAME}
    mkdir ${PORT_NAME}
    cp -v ${ARCHIVE_PATH}/${PORT_NAME}/${PORT_NAME}-${VERSION_STRING}_0.darwin_14.x86_64.tbz2 ${PORT_NAME}/

    echo "========================================"
    echo "3. Update master branch with new port"
    echo "========================================"
    git add ${PORT_FILE}
    git commit -m "Update: ${VERSION_STRING}"
    git pull --rebase -s recursive -X ours origin master
    git push origin master:master

    echo "========================================"
    echo "4. Update gh-pages branch"
    echo "========================================"
    git branch -D gh-pages
    git checkout --orphan gh-pages
    rm .git/index
    tar cvf ports.tar ports/PortIndex ports/PortIndex.quick ports/lang/lean/Portfile
    git add -f ports.tar
    git add -f ${PORT_NAME}/${PORT_NAME}-${VERSION_STRING}_0.darwin_14.x86_64.tbz2
    git commit -m "ports.tar: ${VERSION_STRING} [skip ci]"
    git push origin --force gh-pages:gh-pages
    git checkout -f master
    rm -rf ports.tar ${PORT_NAME}/${PORT_NAME}-${VERSION_STRING}_0.darwin_14.x86_64.tbz2
else
    echo "Nothing to do."
fi
mv ${REPO_NAME}/CURRENT_HASH ${REPO_NAME}/PREVIOUS_HASH

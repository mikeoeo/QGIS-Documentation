#!/bin/bash

LOCALES='de nl'

if [ $1 ]; then
  LOCALES=$1
fi


# Create / update the translation catalogue - this will generate the master .pot files
mkdir -p i18n/pot
BUILDDIR=build
sphinx-build -d ${BUILDDIR}/doctrees -b gettext source i18n/pot/

# Now iteratively update the locale specific .po files with any new strings needed translation

for LOCALE in ${LOCALES}
do
  echo "Updating translation catalog for ${LOCALE}:"
  echo "------------------------------------"
  mkdir -p i18n/${LOCALE}/LC_MESSAGES

  # Clone the en resources and then overwrite with any localised versions of the same files.
  cp -r resources/en/* static/
  PODIR=resources/${LOCALE}
  if [ -d $PODIR ];
  then
      cp -r ${PODIR}/* static/
  fi

  # Merge or copy all the updated pot files over to locale specific po files
  for FILE in `ls i18n/pot`
  do
    POTFILE=i18n/pot/${FILE}
    POFILE=i18n/${LOCALE}/LC_MESSAGES/`basename ${POTFILE} .pot`.po
    if [ -f $POFILE ];
    then
      echo "Updating strings for ${POFILE}"
      msgmerge -U ${POFILE} ${POTFILE}
    else
      echo "Creating ${POFILE}"
      cp ${POTFILE} ${POFILE} 
    fi
  done
done

# Now get rid of temporary POT files
rm -rf i18n/pot
rm -rf static/*
git checkout static/EVERYTHING_YOU_PUT_HERE_WILL_BE_DESTROYED



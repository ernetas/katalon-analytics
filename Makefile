NAME = katalon-analytics
# Major version relates to upstream version of Katalon Report Uploader
MAJOR = 0.1
# Minor version is only for versioning this package
MINOR = 0
VERSION = $(MAJOR)-$(MINOR)
DESCRIPTION = Katalon Analytics

.PHONY: all prepare build release

all: prepare build
CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

prepare:
	mkdir -p package/usr/bin
	echo " -- Ernestas Lukosevicius <ernestas@samesystem.com> $(date -R)" >> package/DEBIAN/changelog
	sed -i "s/version/$(VERSION)/g" package/DEBIAN/changelog
	sed -i "s/package/$(NAME)/g" package/DEBIAN/changelog
	cat package/DEBIAN/changelog
	sed -i "s/version/$(VERSION)/g" package/DEBIAN/control
	sed -i "s/description/$(DESCRIPTION)/g" package/DEBIAN/control
	sed -i "s/package/$(NAME)/g" package/DEBIAN/control
	mkdir -p package/usr/share/katalon-report-uploader/
	wget http://download.katalon.com/resources/katalon-report-uploader-0.0.1.jar -O katalon-report-uploader.jar
	mv katalon-report-uploader.jar package/usr/share/katalon-report-uploader/

build:
	docker pull ernestas/debian-packaging
	docker run --rm -v $(CURRENT_DIR):/wd -w /wd -u root:root -ti ernestas/debian-packaging dpkg -b ./package/ $(NAME)-$(VERSION).deb
	docker run --rm -v $(CURRENT_DIR):/wd -w /wd -u root:root -ti ernestas/debian-packaging dpkg --info $(NAME)-$(VERSION).deb
	docker run --rm -v $(CURRENT_DIR):/wd -w /wd -u root:root -ti ernestas/debian-packaging dpkg -c $(NAME)-$(VERSION).deb

release:
	push-deb $(NAME)-$(VERSION).deb

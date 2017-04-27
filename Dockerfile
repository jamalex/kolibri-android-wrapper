# ubuntu 14 should come with gcc-4.8, if not, and the build failed, can try install gcc-4.8
FROM ubuntu:14.04.5

# install required ubuntu packages
RUN apt-get update
RUN sudo apt-get install -y wget unzip software-properties-common

# get the right version of NDK and SDK
RUN wget https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
RUN wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
# unpack the NDK and SDK downloads
RUN unzip android-ndk-r13b-linux-x86_64.zip
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz

# TODO:
# This is a temporary solution to fetch python build and kolibri.pex
# fetching python build from GoogleDrive(for some reason, it also downloads some crap like 0B5xDzmtBJIQlOHJfM1J3bW9OeXc that need to be removed)
ADD https://doc-0g-2c-docs.googleusercontent.com/docs/securesc/lh154k315dbgtv334js9quoupas3cnps/asmk1vmbb1ecsa77n3oen9aetmij60m2/1493244000000/05796788971138871480/05796788971138871480/0B5xDzmtBJIQlOHJfM1J3bW9OeXc?h=10311220666211206215&e=download /kolibri_apk/app/src/main/res/raw/
RUN rm /kolibri_apk/app/src/main/res/raw/0B5xDzmtBJIQlOHJfM1J3bW9OeXc
ADD https://doc-0g-2c-docs.googleusercontent.com/docs/securesc/lh154k315dbgtv334js9quoupas3cnps/07727crmf6djr0m1jd8fkq2iv2rk6grs/1493244000000/05796788971138871480/05796788971138871480/0B5xDzmtBJIQlVXYzVHFUMVVWeVE?h=10311220666211206215&e=download /kolibri_apk/app/src/main/res/raw/
RUN rm /kolibri_apk/app/src/main/res/raw/0B5xDzmtBJIQlVXYzVHFUMVVWeVE
# fetching the kolibri.pex file from Jamie's Slack file share.
ADD https://files.slack.com/files-pri/T0KT5DC58-F4ZTYPAT0/download/kolibri-v0.3.1-beta3.pex \
    kolibri_apk/app/src/main/res/raw/kolibri.pex
# install JDK 8
RUN sudo apt-add-repository ppa:webupd8team/java
RUN sudo apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN sudo apt-get install -y oracle-java8-installer
RUN apt-get clean
# Copy kolibri_apk into the container
ADD /kolibri_apk/. /kolibri_apk
# modify gradle.properties file to point to the newly installed JDK 8
WORKDIR /kolibri_apk
RUN sed -i '1s@.*@org.gradle.java.home=/usr/lib/jvm/java-8-oracle@' /kolibri_apk/gradle.properties
# create local.properties file to specify SDK path and NDK path
RUN printf "ndk.dir=/android-ndk-r13b\nsdk.dir=/android-sdk-linux" > local.properties
# configure SDK
RUN echo y | /android-sdk-linux/tools/android update sdk --all --filter platform-tools,build-tools-25.0.0,android-22 --no-ui --force
# generate a debugging APK
RUN ./gradlew assembleDebug

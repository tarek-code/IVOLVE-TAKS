#!/bin/bash

echo "===== Java & Gradle Setup Script ====="
echo

# 1️⃣ Uninstall existing Java
echo "Uninstalling existing Java versions..."
sudo yum remove -y java* || true

# 2️⃣ Uninstall existing Gradle
echo "Uninstalling existing Gradle..."
sudo rm -rf /opt/gradle
sudo rm -f /usr/bin/gradle
sudo rm -f /usr/local/bin/gradle || true

echo
# 3️⃣ Ask user for Java version
read -p "Enter Java version to install (8, 11, 17 recommended for Gradle compatibility): " JAVA_VER

case $JAVA_VER in
    8)
        JAVA_PKG="java-1.8.0-openjdk-devel"
        ;;
    11)
        JAVA_PKG="java-11-openjdk-devel"
        ;;
    17)
        JAVA_PKG="java-17-openjdk-devel"
        ;;
    *)
        echo "Invalid Java version, defaulting to 11"
        JAVA_PKG="java-11-openjdk-devel"
        ;;
esac

# 4️⃣ Install Java
echo "Installing Java $JAVA_VER..."
sudo yum install -y $JAVA_PKG

# 5️⃣ Set JAVA_HOME
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which javac))))
echo "JAVA_HOME set to $JAVA_HOME_PATH"
export JAVA_HOME=$JAVA_HOME_PATH
export PATH=$JAVA_HOME/bin:$PATH

# 6️⃣ Ask user for Gradle version
read -p "Enter Gradle version to install (recommended 6.9 or 7.6): " GRADLE_VER

if [ -z "$GRADLE_VER" ]; then
    GRADLE_VER="7.6"
fi

# 7️⃣ Download and install Gradle
echo "Installing Gradle $GRADLE_VER..."
cd /tmp
wget https://services.gradle.org/distributions/gradle-${GRADLE_VER}-bin.zip
sudo unzip -qo gradle-${GRADLE_VER}-bin.zip -d /opt/
sudo ln -sfn /opt/gradle-${GRADLE_VER}/bin/gradle /usr/bin/gradle
rm gradle-${GRADLE_VER}-bin.zip

# 8️⃣ Verify installations
echo
echo "===== Verification ====="
java -version
javac -version
gradle -v

echo
echo "Setup complete! Your Java $JAVA_VER and Gradle $GRADLE_VER are ready to use."


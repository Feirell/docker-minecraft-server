FROM openjdk:18

# create /server and /server/data
RUN mkdir -p /server/data

# The minecraft server tcp port
EXPOSE 25565/tcp

# container-content contains three files:
#   - eula.txt    This is a accepted eula which is used to start the server with out the need to accept it separetly
#   - server.jar  The server.jar provided by mojang, can be replaced to start another version.
#   - start.bash  A bash to move the eula if not already present.
COPY container-content /server

# Makes the bash accessable and executable
RUN chmod -R 777 /server

# Change the working directory, so the world, server.properties file etc. will be placed in a new directory,
# which can be used by a volume to persist and share the world and the settings
WORKDIR /server/data

# Those are the start commands. The first one will start the bash which will copy the accepted eula to the directory
# if non is present the second one starts the actual server. It is both placed here and not in the bash to use the
# stdin and stdout of the server so to be able to access the server and issue commands.
CMD ../start.bash && java -Xms512m -Xmx4g -jar ../server.jar --nogui

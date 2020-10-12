#!/bin/sh
shopt -s nocasematch

git_private=false
git_email=$(git config user.email)
git_name=$(git config user.name)
repo_name=${PWD##*/}	
my_access_token=$(git config user.password)
README_FILENAME="README.md"
GITIGNORE_FILENAME=".gitignore"
GITIGNORE_STRING_DATA="/git-create.sh"

# Create a user email for gitHub repository
provide_email() {
	while [[ -z $git_email ]]
	do	
		read -p 'Give me your gitHub email: ' git_email
		if [[ ! -z $git_email ]]; then
			git config --global user.email $git_email
			break
		else 
			echo "Please enter a valid gitHub email"
		fi		
	done
}

# Create the gitHub repository name (Usually takes the current folder name if exists)
provide_repository_name() {
	while [[ -z $repo_name ]]
	do	
		read -p 'Give me your gitHub repository name: ' repo_name
		if [[ ! -z $repo_name ]]; then
			break
		else 
			echo "Please enter a valid gitHub repository name"
		fi		
	done
}

# Create the githHub user name for the repository
provide_git_name() {
	while [[ -z $git_name ]]
	do	
		read -p 'Give me your gitHub name: ' git_name
		if [[ ! -z $git_name ]]; then
			git config --global user.name $git_name
			break
		else 
			echo "Please enter a valid gitHub name"
		fi		
	done
}

# Create the githHub user name for the repository
provide_git_token() {
	while [[ -z $my_access_token ]]
	do	
		read -p 'Give me your gitHub token: ' my_access_token
		if [[ ! -z $my_access_token ]]; then
			git config --global user.password $my_access_token
			break
		else 
			echo "Please enter a valid gitHub token"
		fi		
	done
}

# Create description for the repository
provide_repository_description() {
	while [[ -z $repo_description ]]
	do	
		read -p 'Give me the repository description: ' repo_description
		if [[ ! -z $repo_description ]]; then
			break
		else 
			echo "Please enter a description"
		fi		
	done
}

# deside if the repository will be public or private
private_repository() {
	while [[ $private_repos != 'Yes' ]] || [[ $private_repos != 'No' ]] || [[ -z $private_repos ]]
	do	
		read -p 'Do you want this repository to be private? [Yes] [No]: ' private_repos
		if [[ $private_repos == 'Yes' ]] || [[ $private_repos == 'No' ]] && [[ ! -z $private_repos ]]; then
			if [[ $private_repos == 'Yes' ]]; then
				git_private=true
				break
			elif [[ $private_repos == 'No' ]]; then
				git_private=false
				break
			fi	
		else 
			echo "Please enter a valid choice [Yes] [No]"
		fi		
	done
}

# if README file does not exist then create it
# write to the README file the new data
create_readme() {
if [ ! -f ${README_FILENAME} ]; then 
	touch ${README_FILENAME} 
fi

cat > ${README_FILENAME} <<EOL
# $repo_name
$repo_description
EOL
}

# if gitignore file contains the string dont't write it again into the file 
create_gitignore() {
if ! grep -q ${GITIGNORE_STRING_DATA} ${GITIGNORE_FILENAME}; then
	cat >> ${GITIGNORE_FILENAME} <<EOL
/git-create.sh
EOL
fi
}

# initialize the local repository
init_local_repo() {
	git init
	git add .
	git commit -m 'Init'
}

#initialize the global repository
init_global_repo() {
	curl -H "Authorization: token "$my_access_token"" https://api.github.com/user/repos -d "{\"name\":\"$repo_name\", \"description\": \"$repo_description\", \"private\": "$git_private"}"
}

# Give the public URL repository and push the files on it
push_to_global_repo() {
	git remote add origin https://github.com/${git_name}/${repo_name}.git
	git push --set-upstream origin master
}


provide_email
provide_repository_name
provide_git_name
provide_git_token
provide_repository_description
private_repository
create_readme
create_gitignore
init_local_repo
init_global_repo
push_to_global_repo



FROM node:lts-alpine

# make the 'app' folder the current working directory
WORKDIR /app

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

# install project dependencies
RUN npm install

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY . .

# build app for production with minification
RUN npm run build

EXPOSE 5046
CMD ["npm", "run", "serve"]

#docker run --name scalyshop-v2-frontend -p 5046:5046 -d registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend
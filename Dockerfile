FROM node:lts-alpine

# make the 'app' folder the current working directory
WORKDIR /app

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

# install project dependencies
RUN npm install

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY . .

# Set environment variables for the frontend to connect to the backend service
ENV VITE_BACKEND_HOST=backend.k8s.orb.local
ENV VITE_BACKEND_PORT=80

# build app for production with minification
RUN npm run build

# Start the application
CMD ["npm", "run", "serve"]

# Example to run the Docker container:
# docker run --name scalyshop-v2-frontend -p 80:80 -d registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend
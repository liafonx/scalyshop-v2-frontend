FROM --platform=linux/amd64 node:lts-alpine

# make the 'app' folder the current working directory
WORKDIR /app

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

# install project dependencies
RUN npm install

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY . .

# Set environment variables for the frontend to connect to the backend service
ENV VITE_BACKEND_HOST=192.168.194.247
ENV VITE_BACKEND_PORT=5000

# build app for production with minification
RUN npm run build

# Expose port 80 for the application
EXPOSE 5046

# Start the application
CMD ["npm", "run", "serve"]

# Example to run the Docker container:
# docker run --name scalyshop-v2-frontend -p 80:80 -d registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend
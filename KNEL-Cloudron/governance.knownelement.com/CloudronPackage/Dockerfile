FROM cloudron/base:4.2.0

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    git \
    curl \
    ruby-full \
    nodejs \
    npm \
    imagemagick \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libyaml-dev \
    libssl-dev \
    libreadline-dev \
    supervisor \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Update npm and install yarn
RUN npm install -g yarn

# Set Ruby and NodeJS versions
ENV RUBY_VERSION=3.2.8
ENV NODE_VERSION=18.20.3

# Ensure correct nodejs version (Node.js is already installed in base image)
RUN n ${NODE_VERSION}

# Create app directory structure
RUN mkdir -p /app/code /app/data /tmp/data

# Clone the app
RUN git clone https://github.com/consuldemocracy/consuldemocracy.git /app/code
WORKDIR /app/code

# Install bundler
RUN gem install bundler

# Install gems
RUN bundle install --deployment --without development test

# Install JavaScript dependencies
RUN yarn install

# Precompile assets
RUN SECRET_KEY_BASE=precompilation_key RAILS_ENV=production bundle exec rake assets:precompile

# Configure Nginx
RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/consuldemocracy.conf

# Configure Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/consuldemocracy.conf

# Add initialization script for /app/data
COPY init-data.sh /app/code/
RUN chmod +x /app/code/init-data.sh

# Copy backup script
COPY backup.sh /app/code/
RUN chmod +x /app/code/backup.sh

# Copy database configuration
COPY database.yml /app/code/config/database.yml

# Copy secrets configuration template
COPY secrets.yml /app/code/config/secrets.yml

# Add LDAP configuration
COPY ldap.yml /app/code/config/ldap.yml

# Copy oauth integration config
COPY oauth.rb /app/code/config/initializers/oauth.rb

# Copy the startup script
COPY start.sh /app/code/
RUN chmod +x /app/code/start.sh

# Set appropriate permissions
RUN chown -R cloudron:cloudron /app/code

# Configure app for production
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

# Entrypoint
CMD ["/app/code/start.sh"]
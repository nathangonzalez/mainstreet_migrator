# Making Main Street Migrator Accessible via WWW

This guide explains how to make your locally running Main Street Migrator application accessible from the internet.

## Option 1: Using Cloudflare Tunnel

### Prerequisites
- Install Cloudflare's `cloudflared` tool
  - Windows: `winget install Cloudflare.cloudflared`
  - macOS: `brew install cloudflared`

### Steps
1. Make sure your UAT server is running on port 8081
2. Open a new terminal and run:
   ```
   cloudflared tunnel --url http://localhost:8081
   ```
3. Cloudflare will provide a temporary URL (like `https://something-random.trycloudflare.com`)
4. Share this URL with your testers

## Option 2: Using ngrok

### Prerequisites
- Install ngrok from https://ngrok.com/download

### Steps
1. Make sure your UAT server is running on port 8081
2. Open a new terminal and run:
   ```
   ngrok http 8081
   ```
3. ngrok will provide a temporary URL (like `https://1234abcd.ngrok.io`)
4. Share this URL with your testers

## Option 3: Port Forwarding (More Permanent, Requires Router Access)

### Steps
1. Log in to your router's admin panel (typically at 192.168.0.1 or 192.168.1.1)
2. Find the "Port Forwarding" section
3. Create a new rule:
   - External port: 8081 (or another port of your choice)
   - Internal port: 8081
   - Internal IP: Your computer's local IP address (shown in the UAT server output)
   - Protocol: TCP
4. Apply the settings
5. Find your public IP address by visiting https://whatismyip.com
6. Share your public IP and port (http://your.public.ip:8081)

## Option 4: Using a Dynamic DNS Service

For a more permanent solution with a memorable URL:

1. Sign up for a dynamic DNS service like No-IP or DynDNS
2. Install their client software to keep your dynamic IP updated
3. Configure port forwarding as in Option 3
4. Share your dynamic DNS URL with port (http://yourname.no-ip.org:8081)

## Important Security Notes

1. These methods expose your computer to the internet. Only keep the tunnel/port forwarding open while testing.
2. Make sure your computer has a firewall enabled.
3. For production deployment, use a proper hosting service like Render, Heroku, or AWS instead of exposing your local computer.

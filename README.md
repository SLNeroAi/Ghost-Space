<!DOCTYPE html>

<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GOST-MD 2.0 Documentation</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<style>
body {
font-family: 'Inter', sans-serif;
background-color: #f7f7f7;
line-height: 1.6;
}
.container {
max-width: 900px;
}
pre {
background-color: #1e293b; /* Slate-800 for dark code background /
color: #f1f5f9; / Light text */
padding: 1rem;
border-radius: 0.5rem;
overflow-x: auto;
font-size: 0.9rem;
}
h1, h2, h3 {
margin-top: 1.5rem;
margin-bottom: 0.75rem;
font-weight: 700;
}
</style>
</head>
<body class="p-4 md:p-8">

<div class="container mx-auto bg-white shadow-xl rounded-lg p-6 md:p-10 border border-gray-100">

    <!-- Usage Warning -->
    <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded-md mb-8">
        <div class="flex items-center">
            <svg class="h-6 w-6 text-yellow-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.3 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <p class="font-semibold text-yellow-800">⚠️ Usage Warning</p>
        </div>
        <p class="mt-2 text-sm text-yellow-700">This project is provided for **personal and educational use only**.</p>
        <ul class="list-none mt-2 text-sm text-yellow-700 space-y-1 ml-4">
            <li class="flex items-center">
                <span class="mr-2 text-red-600 font-bold">❌</span> Commercial use or reselling is **strictly prohibited**.
            </li>
            <li class="flex items-center">
                <span class="mr-2 text-green-600 font-bold">✅</span> You may use or modify this project for improvement purposes, **but proper credit to the original owner is required**.
            </li>
        </ul>
        <p class="mt-2 text-xs text-yellow-700 italic">Please respect the licensing terms when using this project.</p>
    </div>
    
    <!-- Header -->
    <h1 class="text-4xl text-gray-900 mb-3">GHOST VPN Monitor (GOST-MD 2.0)</h1>
    
    <!-- License Badge -->
    <p class="mb-6">
        <a href="https://creativecommons.org/licenses/by-nc/4.0/" target="_blank" rel="noopener noreferrer">
            <img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg" alt="License: CC BY-NC 4.0" class="inline-block">
        </a>
    </p>

    <p class="text-lg text-gray-600 mb-8">
        GOST-MD is a simple tool designed to help users monitor and manage their network traffic usage through an accessible web interface.
    </p>

    <hr class="mb-8 border-gray-200" />

    <!-- Installation & Setup -->
    <h2 class="text-3xl text-gray-800 border-b pb-2">🚀 Installation & Setup</h2>
    <p class="mt-4 mb-4 text-gray-700">
        Follow these steps to install and run GHOST VPN Monitor on your server.
    </p>

    <!-- Prerequisites -->
    <h3 class="text-2xl text-gray-800 mt-6 mb-3">### Prerequisites (Required Ports)</h3>
    <p class="mb-4 text-gray-700">
        Before installation, ensure the following ports are open on your server:
    </p>
    <ul class="list-disc list-inside space-y-2 ml-4 text-gray-700">
        <li>
            **Port 80 (HTTP):** Required to obtain an **SSL certificate** during the setup process.
        </li>
        <li>
            **Port 5000:** Necessary to access the **GHOST VPN web application** after installation.
        </li>
    </ul>

    <!-- Installation Steps -->
    <h3 class="text-2xl text-gray-800 mt-6 mb-3">### Installation Steps</h3>

    <div class="space-y-4">
        <!-- Step 1 -->
        <p class="font-semibold text-gray-800">1. Identify Your OS Username:</p>
        <p class="text-gray-700">
            Run the following command to check your current operating system username:
        </p>
        <pre><code class="language-bash">whoami</code></pre>

        <!-- Step 2 -->
        <p class="font-semibold text-gray-800">2. Run the Installer Script:</p>
        <p class="text-gray-700">
            Execute the command below to automatically download and install GHOST VPN Monitor:
        </p>
        <pre><code class="language-bash">bash &lt;(curl -s https://raw.githubusercontent.com/Kasun-k/GHOST-VPN/main/Ghost-Mx.sh)</code></pre>
    </div>
    
    <hr class="my-8 border-gray-200" />

    <!-- Accessing the Web Application -->
    <h2 class="text-3xl text-gray-800 border-b pb-2">🌐 Accessing the Web Application</h2>
    <p class="mt-4 mb-4 text-gray-700">
        Once the installation is complete, you can access the GHOST VPN management dashboard via your server's IP address and the designated port:
    </p>

    <ul class="list-none space-y-2 bg-blue-50 border-l-4 border-blue-500 p-4 rounded-md">
        <li class="text-blue-900">
            <span class="font-mono bg-blue-200 px-2 py-0.5 rounded text-sm">HTTP:</span> 
            <code class="font-bold text-lg">http://your-server-ip:5000</code>
        </li>
        <li class="text-blue-900">
            <span class="font-mono bg-blue-200 px-2 py-0.5 rounded text-sm">HTTPS:</span> 
            <code class="font-bold text-lg">https://your-server-ip:5000</code> <span class="text-sm">(If SSL is Enabled)</span>
        </li>
    </ul>

</div>


</body>
</html>
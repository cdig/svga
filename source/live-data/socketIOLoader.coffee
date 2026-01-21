
# One-time Makes "socket.io" when it imports successfuly. the global io object is then safe to use
s = document.createElement 'script'
s.src = 'https://cdn.socket.io/4.8.1/socket.io.min.js'
s.integrity = 'sha384-mkQ3/7FUtcGyoppY6bz/PORYoGqOl7/aSUMn2ymDOJcapfS6PHqxhRTMh1RR0Q6+'
s.crossOrigin = 'anonymous'
s.onerror = -> console.error 'Failed to load Socket.IO'
s.onload = -> Make "socket.io"
document.head.appendChild s
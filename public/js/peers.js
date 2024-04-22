document.addEventListener('alpine:init', () => {
    Alpine.data('data', () => ({
        peers: [],
        init() {
            var self = this;
            fetch('/api/v1/peers') // api for the get request
                .then(response => response.json())
                .then(data => self.peers = data);
        }
    }))
});

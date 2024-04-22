document.addEventListener('alpine:init', () => {
    Alpine.data('data', () => ({
        volumes: [],
        init() {
            var self = this;
            fetch('/api/v1/volumes') // api for the get request
                .then(response => response.json())
                .then(data => self.volumes = data);
        }
    }))
});

document.addEventListener('alpine:init', () => {
    Alpine.data('data', () => ({
        peers: [],
        peerAddress: "",
        showAddPeer: false,
        init() {
            var self = this;
            fetch('/api/v1/peers') // api for the get request
                .then(response => response.json())
                .then(data => self.peers = data);
        },
        addPeer() {
            fetch('/api/v1/peers', {
                method: 'post',
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({address: this.peerAddress})
            })
                .then(response => response.json());
        },
        removePeer(address) {
            var yes = confirm(`Are you sure want to remove the Peer (${address}) from the Cluster?`);
            if (!yes)
                return;

            
        }
    }))
});

    function say()
    {
        window.webkit.messageHandlers.sayhello.postMessage({body: 'hello world!'});
    }

    function alertAction(message) {
        alert(message);
    }
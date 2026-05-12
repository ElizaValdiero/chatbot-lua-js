const input = document.getElementById('input');
const sendBtn = document.getElementById('send-btn');
const messages = document.getElementById('messages');

function AdicionarMensagem(texto, quem) {
    const div = document.createElement('div');
    div.classList.add('msg', quem);
    div.textContent = texto;
    messages.appendChild(div);

    messages.scrollTop = messages.scrollHeight;
}

async function enviar() {
    const texto = input.value.trim()
    if (!texto) return

    AdicionarMensagem(texto, 'usuario')
    input.value = ''

    const typing = document.createElement('div')
    typing.classList.add('typing')
    typing.innerHTML = '<span></span><span></span><span></span>'
    messages.appendChild(typing)
    messages.scrollTop = messages.scrollHeight

    try {
        const resposta = await fetch('http://localhost:8080', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: texto })
        })

        const dados = await resposta.json()

        typing.remove()
        AdicionarMensagem(dados.reply, 'bot')

    } catch (erro) {
        typing.remove()
        AdicionarMensagem('Erro ao conectar com o servidor.', 'bot')
    }
}

sendBtn.addEventListener('click', enviar);
input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') enviar()
})

window.addEventListener('load', () => {
    AdicionarMensagem('Olá! 👋 Seja bem-vindo ao suporte. Como posso te ajudar?', 'bot')
})
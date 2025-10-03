const API_URL = 'http://localhost:5000/books';

document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('add-book-form');
    const bookList = document.getElementById('book-list');

    // Charger les livres
    async function loadBooks() {
        try {
            const response = await fetch(API_URL);
            const books = await response.json();
            bookList.innerHTML = books.map(book => `
                <div class="book-item" data-id="${book.id}">
                    <span>${book.title} par ${book.author}</span>
                    <span class="book-status">${book.read ? '✓ Lu' : '✗ Non lu'}</span>
                    <button class="toggle-read">Marquer ${book.read ? 'non lu' : 'lu'}</button>
                    <button class="delete-book">Supprimer</button>
                </div>
            `).join('');

            // Ajouter les écouteurs d'événements
            document.querySelectorAll('.toggle-read').forEach(button => {
                button.addEventListener('click', toggleReadStatus);
            });

            document.querySelectorAll('.delete-book').forEach(button => {
                button.addEventListener('click', deleteBook);
            });
        } catch (error) {
            console.error('Erreur lors du chargement des livres:', error);
        }
    }

    // Ajouter un livre
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const title = document.getElementById('title').value;
        const author = document.getElementById('author').value;

        try {
            await fetch(API_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ title, author })
            });

            // Recharger la liste et réinitialiser le formulaire
            loadBooks();
            form.reset();
        } catch (error) {
            console.error('Erreur lors de l\'ajout du livre:', error);
        }
    });

    // Marquer un livre comme lu/non lu
    async function toggleReadStatus(e) {
        const bookItem = e.target.closest('.book-item');
        const bookId = bookItem.dataset.id;

        try {
            const currentStatus = bookItem.querySelector('.book-status').textContent.includes('✓');
            await fetch(`${API_URL}/${bookId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ read: !currentStatus })
            });

            loadBooks();
        } catch (error) {
            console.error('Erreur lors du changement de statut:', error);
        }
    }

    // Supprimer un livre
    async function deleteBook(e) {
        const bookItem = e.target.closest('.book-item');
        const bookId = bookItem.dataset.id;

        try {
            await fetch(`${API_URL}/${bookId}`, {
                method: 'DELETE'
            });

            loadBooks();
        } catch (error) {
            console.error('Erreur lors de la suppression du livre:', error);
        }
    }

    // Charger les livres au démarrage
    loadBooks();
});

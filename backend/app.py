from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Activer CORS pour les requêtes frontend
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///library.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    author = db.Column(db.String(100), nullable=False)
    read = db.Column(db.Boolean, default=False)

@app.route('/books', methods=['GET'])
def get_books():
    books = Book.query.all()
    return jsonify([{
        'id': book.id, 
        'title': book.title, 
        'author': book.author, 
        'read': book.read
    } for book in books])

@app.route('/books', methods=['POST'])
def add_book():
    data = request.json
    new_book = Book(
        title=data['title'], 
        author=data['author'], 
        read=data.get('read', False)
    )
    db.session.add(new_book)
    db.session.commit()
    return jsonify({
        'id': new_book.id,
        'title': new_book.title, 
        'author': new_book.author, 
        'read': new_book.read
    }), 201

@app.route('/books/<int:book_id>', methods=['PUT'])
def update_book(book_id):
    book = Book.query.get_or_404(book_id)
    data = request.json
    book.read = data.get('read', book.read)
    db.session.commit()
    return jsonify({
        'id': book.id,
        'title': book.title, 
        'author': book.author, 
        'read': book.read
    })

@app.route('/books/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    book = Book.query.get_or_404(book_id)
    db.session.delete(book)
    db.session.commit()
    return '', 204

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, debug=True)

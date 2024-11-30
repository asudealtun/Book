import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Int "mo:base/Int";

actor Bookstore {
    // Book structure
    public type Book = {
        id: Nat;
        title: Text;
        author: Text;
        price: Nat;
        publishedTime: Time.Time;
        stock: Nat;
    };

    // Initialize state variables
    private stable var nextBookId: Nat = 0;
    private var books = HashMap.HashMap<Nat, Book>(0, Nat.equal, Hash.hash);

    // Add a new book
    public func addBook(title: Text, author: Text, price: Nat, stock: Nat) : async Nat {
        let bookId = nextBookId;
        let currentTime = Time.now();
       
        let newBook: Book = {
            id = bookId;
            title = title;
            author = author;
            price = price;
            publishedTime = currentTime;
            stock = stock;
        };
       
        books.put(bookId, newBook);
        nextBookId += 1;
        return bookId;
    };

    // Get book details
    public query func getBook(bookId: Nat) : async Result.Result<Book, Text> {
        switch (books.get(bookId)) {
            case (null) {
                #err("Book not found");
            };
            case (?book) {
                #ok(book);
            };
        };
    };

    // Update book stock
    public func updateStock(bookId: Nat, newStock: Nat) : async Result.Result<(), Text> {
        switch (books.get(bookId)) {
            case (null) {
                #err("Book not found");
            };
            case (?existingBook) {
                let updatedBook: Book = {
                    id = existingBook.id;
                    title = existingBook.title;
                    author = existingBook.author;
                    price = existingBook.price;
                    publishedTime = existingBook.publishedTime;
                    stock = newStock;
                };
                books.put(bookId, updatedBook);
                #ok();
            };
        };
    };

    // Get all books published after a certain time
    public query func getBooksPublishedAfter(timestamp: Time.Time) : async [Book] {
        let buffer = Buffer.Buffer<Book>(0);
        for ((_, book) in books.entries()) {
            if (book.publishedTime > timestamp) {
                buffer.add(book);
            };
        };
        Buffer.toArray(buffer);
    };

    // Get publication time in human-readable format
    public func getPublicationTimeString(bookId: Nat) : async Result.Result<Text, Text> {
        switch (books.get(bookId)) {
            case (null) {
                #err("Book not found");
            };
            case (?book) {
                let timestamp = book.publishedTime;
                let milliseconds = timestamp / 1_000_000; // Convert nanoseconds to milliseconds
                #ok("Publication Timestamp (ms): " # Int.toText(milliseconds));
            };
        };
    };
}

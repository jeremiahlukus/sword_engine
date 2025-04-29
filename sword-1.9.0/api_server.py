#!/usr/bin/env python3

from flask import Flask, jsonify, request
import os
import sys
import logging
import Sword

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
markupfilt = Sword.MarkupFilterMgr(Sword.FMT_PLAIN)
library = Sword.SWMgr()

# Set up the markup filter
def filter_text(text):
    # Remove XML tags but keep their content
    text = str(text)
    # Handle transChange tags specially
    text = text.replace('<transChange type="added">', '[').replace('</transChange>', ']')
    # Remove chapter tags
    text = text.replace('<chapter eID="gen30993" osisID="2Tim.1"/>', '')
    # Remove any remaining XML tags
    text = text.replace('<', '&lt;').replace('>', '&gt;')
    return text.strip()

# Log available modules at startup
logger.debug(f"SWORD library path: {library.prefixPath}")
modules = {str(name): module for name, module in library.getModules().items()}
logger.debug(f"Available modules: {list(modules.keys())}")

@app.route('/health')
def health_check():
    return jsonify({
        'status': 'ok',
        'modules_found': list(modules.keys()),
        'library_path': str(library.prefixPath)
    })

@app.route('/versions')
def get_versions():
    try:
        available_modules = list(modules.keys())
        if not available_modules:
            return jsonify({'error': 'No Bible modules found'}), 404
        return jsonify({
            'versions': [{'name': str(module)} for module in available_modules]
        })
    except Exception as e:
        logger.error(f"Error getting versions: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/books')
def get_books():
    try:
        # Get first available module
        available_modules = list(modules.keys())
        if not available_modules:
            return jsonify({'error': 'No Bible modules found'}), 404
            
        module = modules[available_modules[0]]
        books = []
        
        # Create a verse key for navigation
        key = Sword.VerseKey()
        
        # Get Testament 1 (Old Testament)
        testament1_count = key.bookCount(1)
        for i in range(1, testament1_count + 1):
            key.setTestament(1)
            key.setBook(i)
            key.setChapter(1)
            key.setVerse(1)
            books.append({
                'name': str(key.getBookName()),
                'number': i,
                'abbreviation': str(key.getBookAbbrev()),
                'testament': 'OT'
            })
            
        # Get Testament 2 (New Testament)
        testament2_count = key.bookCount(2)
        for i in range(1, testament2_count + 1):
            key.setTestament(2)
            key.setBook(i)
            key.setChapter(1)
            key.setVerse(1)
            books.append({
                'name': str(key.getBookName()),
                'number': i + testament1_count,
                'abbreviation': str(key.getBookAbbrev()),
                'testament': 'NT'
            })
        
        return jsonify({'books': books})
    except Exception as e:
        logger.error(f"Error getting books: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/books/<book_id>/chapters')
def get_chapters(book_id):
    try:
        available_modules = list(modules.keys())
        if not available_modules:
            return jsonify({'error': 'No Bible modules found'}), 404
            
        module = modules[available_modules[0]]
        key = Sword.VerseKey()
        
        # Find the book by name or abbreviation
        found = False
        for testament in range(1, 3):
            for book in range(1, key.bookCount(testament) + 1):
                key.setTestament(testament)
                key.setBook(book)
                key.setChapter(1)
                key.setVerse(1)
                if str(key.getBookAbbrev()) == book_id or str(key.getBookName()) == book_id:
                    found = True
                    break
            if found:
                break
                
        if not found:
            return jsonify({'error': 'Book not found'}), 404
            
        chapters = []
        for i in range(1, key.getChapterMax() + 1):
            chapters.append({'number': i})
            
        return jsonify({'chapters': chapters})
    except Exception as e:
        logger.error(f"Error getting chapters: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/books/<book_id>/chapters/<int:chapter_id>/verses')
def get_verses(book_id, chapter_id):
    try:
        available_modules = list(modules.keys())
        if not available_modules:
            return jsonify({'error': 'No Bible modules found'}), 404
            
        module = modules[available_modules[0]]
        key = Sword.VerseKey()
        
        # Find the book by name or abbreviation
        found = False
        for testament in range(1, 3):
            for book in range(1, key.bookCount(testament) + 1):
                key.setTestament(testament)
                key.setBook(book)
                key.setChapter(1)
                key.setVerse(1)
                if str(key.getBookAbbrev()) == book_id or str(key.getBookName()) == book_id:
                    found = True
                    break
            if found:
                break
                
        if not found:
            return jsonify({'error': 'Book not found'}), 404
            
        if chapter_id < 1 or chapter_id > key.getChapterMax():
            return jsonify({'error': 'Chapter not found'}), 404
            
        verses = []
        key.setChapter(chapter_id)
        verse_max = key.getVerseMax()
        
        for verse in range(1, verse_max + 1):
            key.setVerse(verse)
            module.setKey(key)
            verses.append({
                'number': verse,
                'text': filter_text(module.renderText())
            })
            
        return jsonify({'verses': verses})
    except Exception as e:
        logger.error(f"Error getting verses: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/search')
def search():
    try:
        query = request.args.get('query', '')
        if not query:
            return jsonify({'error': 'Query parameter is required'}), 400
            
        available_modules = list(modules.keys())
        if not available_modules:
            return jsonify({'error': 'No Bible modules found'}), 404
            
        module = modules[available_modules[0]]
        results = []
        
        searchType = Sword.STR_REGEX
        flags = 0
        scope = None
        
        search = module.search(query, searchType, flags, scope)
        if search.getCount():
            while search.hasElements():
                key = search.getElement()
                module.setKey(key)
                results.append({
                    'reference': str(key),
                    'text': markupfilt.doFilter(module.renderText())
                })
                search.popElement()
                
        return jsonify({'results': results})
    except Exception as e:
        logger.error(f"Error searching: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.debug = True  # Enable debug mode
    # Print available modules at startup
    print("Available modules:", list(modules.keys()))
    app.run(host='0.0.0.0', port=8081) 
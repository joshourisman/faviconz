import os
import requests

from bs4 import BeautifulSoup
from flask import Flask
from restless.fl import FlaskResource
from urlparse import urlparse, urljoin

app = Flask(__name__)

DEBUG = os.getenv('DEBUG', 'False') == 'True'


class FaviResource(FlaskResource):
    def detail(self, pk):
        parsed_url = urlparse(pk)
        url = '{}://{}'.format(
            parsed_url.scheme or 'http',
            parsed_url.netloc or parsed_url.path)

        resp = requests.get(url)
        soup = BeautifulSoup(resp.content)

        links = [
            urljoin(url, link['href'])
            for link in soup.find_all('link')
            if 'shortcut' in [rel.lower() for rel in link['rel']]
            and 'icon' in [rel.lower() for rel in link['rel']]
        ]

        favicon_url = None
        for link in links:
            if requests.get(link).content:
                favicon_url = link
                break

        return {
            'url': pk,
            'favicon_url': favicon_url,
        }


FaviResource.add_url_rules(app, '/api/v1/favicons/')

if __name__ == '__main__':
    app.run(debug=DEBUG)

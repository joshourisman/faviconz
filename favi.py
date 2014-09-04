import json
import os
import requests

from bs4 import BeautifulSoup
from cStringIO import StringIO
from flask import Flask, send_file
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

    def bubble_exceptions(self):
        return DEBUG

    def build_response(self, data, status=200):
        if self.request.args.get('file', 'False') == 'True':
            response_value = json.loads(data)
            favicon_url = response_value['favicon_url']
            image_file = StringIO(requests.get(favicon_url).content)

            return send_file(image_file, mimetype='image/x-icon')

        return super(FaviResource, self).build_response(data, status=status)


FaviResource.add_url_rules(app, '/api/v1/favicons/')

if __name__ == '__main__':
    app.run(debug=DEBUG)

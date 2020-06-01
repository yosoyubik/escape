import React, { Component } from 'react';
import _ from 'lodash';


export default class escapeTile extends Component {

  render() {
    return (
      <div className="w-100 h-100 relative bg-white bg-gray0-d ba b--black b--gray1-d">
        <a className="w-100 h-100 db pa2 no-underline" href="/~escape">
          <p className="black white-d absolute f9" style={{ left: 8, top: 8 }}>Escape</p>
          <img
            className="absolute"
            style={{ left: 16, top: 26 }}
            src="/~escape/img/Tile.png"
            width={90}
            height={70} />
        </a>
      </div>
    );
  }
}

window.escapeTile = escapeTile;

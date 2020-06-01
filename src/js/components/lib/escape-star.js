import React, { Component } from 'react';
import { Link } from 'react-router-dom';

import { api } from '/api';

export class EscapeTitle extends Component {
  // drawer to the left
  onClickLeave() {
    // api.escape.leave(this.props.location, this.props.id);
  }
  render() {
    const { props, state } = this;
    return (
      <div>
        <Link to={`/~escape/item/${props.id}`} key={props.id}>
          <div className="w-100 v-mid f7 ph2 z1 pv1">
            <p className="f9 ml1 dib">
              {(props.private) ?
                 <span>
                   <img className="pr1"
                     src="/~escape/img/lock.png"
                     width={10}
                     height={10} />
                 </span>
                : null}
              {props.id}
            </p>

            { (props.location === ("~" + ship)) ?
              (<span className="ph3 f9 pb1 gray2">(local)</span>) :
              (<button className="ph3 f9 pb1 red2 bg-gray0-d b--red2"
               onClick={this.onClickLeave.bind(this)}>
                leave
                <span className="ml1 pointer">x</span>
              </button>)
            }
          </div>
        </Link>
      </div>
    );
  }
}

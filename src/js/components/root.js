import React, { Component } from 'react';
import { BrowserRouter, Route, Switch } from "react-router-dom";
import _ from 'lodash';

import { store } from '/store';
import { api } from '/api';


export class Root extends Component {
  constructor(props) {
    super(props);
    this.state = store.state;
    store.setStateHandler(this.setState.bind(this));
  }

  render() {
    const { props, state } = this;
    return (
      <BrowserRouter>
        <div className="absolute h-100 w-100 bg-gray0-d ph4-m ph4-l ph4-xl pb4-m pb4-l pb4-xl">
          <Route exact path="/~escape"
            render={ () => {
              return (
                <Skeleton
                  activeDrawer="escape"
                  history={props.history} >
                  <div />
                </Skeleton>
              )}} />
        </div>
      </BrowserRouter>
    )
  }
}

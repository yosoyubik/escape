import React, { Component } from 'react';

import { api } from '/api';

import { Route, Link } from 'react-router-dom';
import { Sigil } from '/components/lib/icons/sigil';
import { cite } from '/lib/util';
import { EscapeStar } from '/components/lib/escape-star'


export class EscapeSidebar extends Component {
  // drawer to the left
  onClickLeave() {
    // api.escape.leave(each[1].metadata.location, each[0])
  }
  render() {
    const { props, state } = this;
    let selectedClass = (props.selected === "me") ? "bg-gray4 bg-gray1-d" : "bg-white bg-gray0-d";

    let rootIdentity = <Link
            key={1}
            to={"/~escape/me"}>
            <div
              className={
                "w-100 pl4 pt1 pb1 f9 flex justify-start content-center " +
                selectedClass}>
              <Sigil
              ship={window.ship}
              color="#000000"
              classes="mix-blend-diff"
              size={32}/>
              <p
                className="f9 w-70 dib v-mid ml2 nowrap mono"
                style={{paddingTop: 6}}>
                {cite(window.ship)}
              </p>
            </div>
          </Link>

    let activeClasses = (this.props.activeDrawer === "escape") ? "" : "dn-s";
    let stars = null;
    if (!!props.stars) {
      stars = Object.entries(props.stars).map((each, i) => {
        return (
          <EscapeStar key={i} id={each[0]} data={each[1]} />
        )
      });
    }

    return (
      <div className={"bn br-m br-xl b--gray4 b--gray2-d lh-copy h-100 " +
       "flex-shrink-0 pt3 pt0-m pt0-l pt0-xl relative overflow-y-hidden " +
        "dn-s flex-basis-100-s flex-basis-250-ns " + activeClasses}>

        <a className="db dn-m dn-l dn-xl f8 pb6 pl3" href="/">⟵ Landscape</a>
        <div className="overflow-auto pb8 h-100 pr3">
          <div className="pt1">
            <h2 className="f8 pr4 pb2 pl4 gray2 c-default">Stars</h2>
            { stars }
          </div>
        </div>
      </div>
    );
  }
}

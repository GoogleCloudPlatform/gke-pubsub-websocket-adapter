#!/usr/bin/env node
/**
 * Copyright 2019, Google, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const util = require('util');
const uuidv1 = require('uuid/v1');


/** Maximum number of messages to queue locally un-acked */
// const MAXMSG = 300;
const MAXMSG = 600

/** Deadline for acknowledging messages */
// const ACKDEAD = 90;
const ACKDEAD = 180;

let newSubscription;

/** validate input **/
const TOPICNAME = process.argv[2];
if (!TOPICNAME) {
    console.error('Usage: pulltop <topic-name>');
    process.exit(1);
}

/** manufacture subscription name **/
const SUBNAME = process.env.USER + '-' +
      TOPICNAME.replace(/\//gi, '-') + '-' +
      uuidv1();
let SUB = undefined;

/** process signal handlers to clean up subs **/
const handleExit = function() {
    if (SUB) {
        SUB.delete(function (err) {
            if (err) {
                let error = util.inspect(err);
                console.error(`WARNING: could not delete subscription ${SUBNAME}: ${error}`);
            }
        });
    }
}
process.on('exit', handleExit);
process.on('SIGINT', handleExit);
process.on('SIGTERM', handleExit);

/** PubSub subscription event handlers **/
const onError = function(error) {
    console.error(util.inspect(error));
    process.exit(1);
}
const onMessage = function(message) {
    console.log(`${message.data}`);
    message.ack();
}

/** create subscription, register handler **/
pubsub.createSubscription(TOPICNAME,
                          SUBNAME,
                          {
                              flowControl: {
                                  maxMessages: MAXMSG
                              },
                              ackDeadline: ACKDEAD
                          },
                          function (err, sub) {
                              if (!err) {
                                  SUB = sub;
                                  SUB.on('message', onMessage);
                                  SUB.on('error', onError);
                              } else {
                                  console.error(util.inspect(err));
                                  process.exit(1);
                              }
                          });




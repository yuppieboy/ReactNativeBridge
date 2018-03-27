/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, {Component} from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  NativeEventEmitter,
  NativeModules,
} from 'react-native';
const { PassingManager } = NativeModules

const PassingManagerEmitter = new NativeEventEmitter(PassingManager);

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
  'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
  'Shake or press menu button for dev menu',
});

type Props = {}

type State = {
  title: string
}


export default class App extends Component<Props, State> {

  constructor(props) {
    super(props)
    this.state = {
      title: 'Welcome to React Native!'
    }
  }

  componentDidMount() {
    PassingManagerEmitter.addListener(
      'EventReminder',
      (data) => {
        this.setState({title: JSON.stringify(data)})
      }
    )
    PassingManager.tellClient({"msg":'Hello Client', "array": ["1","2","3"]})
  }

  componentWillUnmount() {
    PassingManagerEmitter.remove()
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          {this.state.title}
        </Text>
        <Text style={styles.instructions}>
          To get started, edit App.js
        </Text>
        <Text style={styles.instructions}>
          {instructions}
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

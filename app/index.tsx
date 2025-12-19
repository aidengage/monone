import React from 'react';
import MapView, {Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import { StyleSheet, View } from 'react-native';

export default function App() {
    return (
        <View style={styles.mask}>
            <View style={styles.container}>
                <MapView renderToHardwareTextureAndroid={true} style={styles.map} /*provider={PROVIDER_GOOGLE}*/
                     initialRegion={{
                         latitude: 38.2037, //N
                         longitude: -85.7724, //W
                         latitudeDelta: 0.09,
                         longitudeDelta: 0.03,
                     }}
                >
                    {markers.map((marker) => (
                        <Marker
                            key={marker.id}
                            title={marker.title}
                            description={marker.description}
                            coordinate={marker.coordinates}
                            // onPress={() => {}}
                        />
                    ))}
                </MapView>
            </View>
        </View>
    );
}

const markers = [
    {
        id: 1,
        title: 'Churchill Downs',
        description: 'Horse racing capital of the nation',
        coordinates: {latitude: 38.2037, longitude: -85.7724},
    }
]

const styles = StyleSheet.create({
    mask: {
        width: '100%',
        height: '100%',
        overflow: 'hidden',
        padding: 20,
    },
    container: {
        overflow: 'hidden',

        borderRadius: 45,
        borderColor: '#ed7070',
    },
    map: {
        width: '100%',
        height: '100%',

        borderRadius: 45,
        borderColor: '#4169ff',
    },
});

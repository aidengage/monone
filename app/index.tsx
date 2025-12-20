import React from 'react';
import { StyleSheet, View } from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';

export default function App() {
    return (
        <View style={styles.mask}>
            <View style={styles.container}>
                <MapView 
                    provider={PROVIDER_GOOGLE}
                    renderToHardwareTextureAndroid={true} 
                    style={styles.map}
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
        flex: 1,
        padding: 20,
    },
    container: {
        flex: 1,
        overflow: 'hidden',
        borderRadius: 45,
        borderWidth: 2,
        borderColor: '#000000',
    },
    map: {
        flex: 1,
        borderRadius: 45,
    },
});

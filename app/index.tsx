import React, { useRef } from 'react';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import {Animated, LayoutAnimation, StyleSheet, UIManager, View} from 'react-native';

export default function App() {
    const mapRef = useRef(null);

    UIManager.setLayoutAnimationEnabledExperimental &&
    UIManager.setLayoutAnimationEnabledExperimental(true);


    const [mapState, setMapState] = React.useState({
        w: '100%',
        h: '100%',
    })

    const centerMapOnMarker = (coordinate: { latitude?: any; longitude?: any; }) => {
        LayoutAnimation.spring();
        setMapState({w: '100%', h: '50%'})

        if (mapRef.current) {
            const region = {
                latitude: coordinate.latitude + 0.02,
                longitude: coordinate.longitude,
            };
            mapRef.current.animateToRegion(region, 500);
        }
    }

    // const onPress = () => {
    //     LayoutAnimation.spring();
    //
    //     setMapState({w: '100%', h: '50%'});
    // }

    return (
        <View style={styles.mask}>
            <View style={styles.container}>
                <MapView
                    ref={mapRef}
                    renderToHardwareTextureAndroid={true}
                    style={[styles.map, {width: mapState.w, height: mapState.h}]}

                    // provider={PROVIDER_GOOGLE}
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
                            onPress={() => centerMapOnMarker(marker.coordinates)}
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

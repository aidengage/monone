import React from 'react';
import MapView, {Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import { StyleSheet, View } from 'react-native';

export default function App() {
    return (
        <View style={styles.container}>
            <MapView style={styles.map} /*provider={PROVIDER_GOOGLE}*/
                initialRegion={{
                    latitude: 38.2037, //N
                    longitude: -85.7724, //W
                    latitudeDelta: 0.09,
                    longitudeDelta: 0.03,
                }}
            >
                <Marker
                    coordinate={{latitude: 38.2037, longitude: -85.7724}}
                    title={"churchill downs"}
                />
            </MapView>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    map: {
        width: '100%',
        height: '100%',
    },
});



// import { Text, View } from "react-native";
//
// export default function Index() {
//   return (
//     <View
//       style={{
//         flex: 1,
//         justifyContent: "center",
//         alignItems: "center",
//       }}
//     >
//       <Text>Edit app/index.tsx to edit this screen.</Text>
//     </View>
//   );
// }

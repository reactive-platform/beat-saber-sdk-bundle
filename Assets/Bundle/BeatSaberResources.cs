using System;
using System.Linq;
using JetBrains.Annotations;
using UnityEditor;
using UnityEngine;

namespace Reactive.BeatSaber {
    [PublicAPI]
    [CreateAssetMenu(fileName = "BeatSaberSDK_Resources", menuName = "Reactive/BeatSaberSDK/Resources")]
    public class BeatSaberResources : ScriptableObject {
        #region Initialization

        private static BeatSaberResources _instance;

        private void Awake() {
            Init();
        }

#if UNITY_EDITOR

        private static void Init() {
            if (_instance != null) return;
            var bundles = AssetDatabase.FindAssets("BeatSaberSDK_Resources");
            var guid = bundles.First();
            var path = AssetDatabase.GUIDToAssetPath(guid);
            _instance = AssetDatabase.LoadAssetAtPath<BeatSaberResources>(path);
        }

#else

        private static void Init() { }
        
#endif

        #endregion

        #region Serialized

        public SpriteCollection sprites;
        public MaterialCollection materials;

        #endregion

        #region Static

        public static SpriteCollection Sprites {
            get {
                Init();
                return _instance!.sprites;
            }
        }

        public static MaterialCollection Materials {
            get {
                Init();
                return _instance!.materials;
            }
        }

        #endregion
    }
}
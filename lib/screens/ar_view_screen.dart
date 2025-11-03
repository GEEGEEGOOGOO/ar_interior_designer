import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../models/furniture_item.dart';
import '../widgets/furniture_selector.dart';
import '../widgets/control_panel.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  Map<String, ARNode> nodes = {};
  Map<String, ARPlaneAnchor> anchors = {};
  FurnitureItem? _selectedFurniture;
  String? _selectedNodeName;
  int _nodeCounter = 0;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Interior Designer'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearScene,
            tooltip: 'Clear Scene',
          ),
        ],
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: FurnitureSelector(
              onFurnitureSelected: (furniture) {
                setState(() => _selectedFurniture = furniture);
              },
              selectedFurniture: _selectedFurniture,
            ),
          ),
          if (_selectedNodeName != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ControlPanel(
                onRotate: _rotateSelectedObject,
                onScaleUp: () => _scaleSelectedObject(true),
                onScaleDown: () => _scaleSelectedObject(false),
                onDelete: _deleteSelectedObject,
              ),
            ),
          Positioned(
            bottom: _selectedNodeName != null ? 120 : 16,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_selectedFurniture == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '👆 Select a furniture item above',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '👇 Tap on a surface to place the item',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: true,
          showPlanes: true,
          showWorldOrigin: true,
          handlePans: false,
          handleRotation: false,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = _onPlaneOrPointTapped;
    this.arObjectManager!.onNodeTap = _onNodeTapped;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AR Session initialized! Move your device to detect surfaces'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (_selectedFurniture == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a furniture item first!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    print('Tap detected! Hit test results: ${hitTestResults.length}');
    
    // If no hit test results, place object at fixed distance in front of camera
    if (hitTestResults.isEmpty) {
      print('No hit results - placing at fixed position');
      await _placeObjectAtFixedPosition(_selectedFurniture!);
      return;
    }
    
    // Try to use any hit result, prefer plane hits
    ARHitTestResult? selectedHit;
    
    // Try to find a plane hit first
    for (var hit in hitTestResults) {
      print('Hit type: ${hit.type}');
      if (hit.type == ARHitTestResultType.plane) {
        selectedHit = hit;
        break;
      }
    }
    
    // If no plane hit, use any hit (including feature points)
    selectedHit ??= hitTestResults.first;
    
    print('Using hit type: ${selectedHit.type}');
    
    try {
      print('Creating anchor...');
      var newAnchor = ARPlaneAnchor(transformation: selectedHit.worldTransform);
      bool? didAddAnchor = await arAnchorManager?.addAnchor(newAnchor);
      
      print('Anchor added: $didAddAnchor');
      if (didAddAnchor == true) {
        await _addFurnitureNode(newAnchor, _selectedFurniture!);
      } else {
        print('Anchor failed, trying fixed position');
        await _placeObjectAtFixedPosition(_selectedFurniture!);
      }
    } catch (e) {
      print('Error adding anchor: $e - trying fixed position');
      await _placeObjectAtFixedPosition(_selectedFurniture!);
    }
  }

  // Place object at fixed distance in front of camera (fallback method)
  Future<void> _placeObjectAtFixedPosition(FurnitureItem furniture) async {
    final nodeName = '${furniture.id}_${_nodeCounter++}';
    
    print('Creating node at fixed position: $nodeName');
    
    // Use local GLTF2 format with simple shapes
    final newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Cube/glTF/Cube.gltf",
      name: nodeName,
      position: vector.Vector3(0, -0.3, -1.0), // 1m in front, 0.3m below camera
      scale: vector.Vector3.all(furniture.defaultScale),
    );

    print('Adding node without anchor');
    bool? didAddNode = await arObjectManager?.addNode(newNode);

    print('Node added result: $didAddNode');
    if (didAddNode == true) {
      nodes[nodeName] = newNode;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${furniture.name} placed in front of camera!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place object'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addFurnitureNode(ARPlaneAnchor anchor, FurnitureItem furniture) async {
    final nodeName = '${furniture.id}_${_nodeCounter++}';
    
    print('Creating node: $nodeName');
    
    final newNode = ARNode(
      type: NodeType.webGLB,
      uri: _getModelUri(furniture.shape),
      name: nodeName,
      position: vector.Vector3(0, 0, 0),
      scale: vector.Vector3.all(furniture.defaultScale),
    );

    print('Adding node to scene with URI: ${newNode.uri}');
    bool? didAddNodeToAnchor = await arObjectManager?.addNode(newNode, planeAnchor: anchor);

    print('Node added result: $didAddNodeToAnchor');
    if (didAddNodeToAnchor == true) {
      nodes[nodeName] = newNode;
      anchors[nodeName] = anchor;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${furniture.name} placed! Loading 3D model...'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place object'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getModelUri(FurnitureShape shape) {
    // Using a single simple cube model that loads reliably
    return 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF/Box.gltf';
  }

  void _onNodeTapped(List<String> nodeNames) {
    if (nodeNames.isEmpty) return;

    setState(() {
      _selectedNodeName = nodeNames.first;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${nodeNames.first}'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Future<void> _rotateSelectedObject() async {
    if (_selectedNodeName == null || !nodes.containsKey(_selectedNodeName)) return;

    final selectedNode = nodes[_selectedNodeName]!;
    final selectedAnchor = anchors[_selectedNodeName]; // May be null
    
    // Remove old node
    await arObjectManager?.removeNode(selectedNode);
    
    // Create new node with updated rotation
    final rotationAngle = 0.785398; // 45 degrees in radians
    final newNode = ARNode(
      type: selectedNode.type,
      uri: selectedNode.uri,
      name: _selectedNodeName!,
      position: selectedNode.position,
      scale: selectedNode.scale,
      rotation: vector.Vector4(0, rotationAngle, 0, 1),
    );
    
    // Add with or without anchor
    if (selectedAnchor != null) {
      await arObjectManager?.addNode(newNode, planeAnchor: selectedAnchor);
    } else {
      await arObjectManager?.addNode(newNode);
    }
    nodes[_selectedNodeName!] = newNode;
  }

  Future<void> _scaleSelectedObject(bool scaleUp) async {
    if (_selectedNodeName == null || !nodes.containsKey(_selectedNodeName)) return;

    final selectedNode = nodes[_selectedNodeName]!;
    final selectedAnchor = anchors[_selectedNodeName]; // May be null
    
    final currentScale = selectedNode.scale;
    final scaleFactor = scaleUp ? 1.2 : 0.8;
    final newScale = vector.Vector3(
      (currentScale.x * scaleFactor).clamp(0.1, 2.0),
      (currentScale.y * scaleFactor).clamp(0.1, 2.0),
      (currentScale.z * scaleFactor).clamp(0.1, 2.0),
    );
    
    // Remove old node
    await arObjectManager?.removeNode(selectedNode);
    
    // Create new node with updated scale
    final newNode = ARNode(
      type: selectedNode.type,
      uri: selectedNode.uri,
      name: _selectedNodeName!,
      position: selectedNode.position,
      scale: newScale,
    );
    
    // Add with or without anchor
    if (selectedAnchor != null) {
      await arObjectManager?.addNode(newNode, planeAnchor: selectedAnchor);
    } else {
      await arObjectManager?.addNode(newNode);
    }
    nodes[_selectedNodeName!] = newNode;
  }

  Future<void> _deleteSelectedObject() async {
    if (_selectedNodeName == null || !nodes.containsKey(_selectedNodeName)) return;

    final selectedNode = nodes[_selectedNodeName]!;
    await arObjectManager?.removeNode(selectedNode);
    
    nodes.remove(_selectedNodeName);
    anchors.remove(_selectedNodeName);
    
    setState(() {
      _selectedNodeName = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Object deleted'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearScene() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Scene'),
        content: const Text('Remove all objects from the scene?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              for (final node in nodes.values) {
                await arObjectManager?.removeNode(node);
              }
              nodes.clear();
              anchors.clear();
              setState(() {
                _selectedNodeName = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
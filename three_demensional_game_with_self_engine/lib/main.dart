import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

// 도형 타입
enum ShapeType {
  cube,
  sphere,
  tetrahedron,
  cylinder,
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('3D Shapes with Drag')),
        body: Shape3DScreen(),
      ),
    );
  }
}

///
/// 1) Shape3DWidget
///    - 선택된 도형 타입(ShapeType)에 따라 다른 3D 모양을 그리는 위젯
///
class Shape3DWidget extends StatelessWidget {
  final ShapeType shapeType;
  final double size;
  final int detail; // 구나 원통 등을 좀 더 면을 많이 쪼갤 때 쓰려고 추가

  const Shape3DWidget({
    Key? key,
    required this.shapeType,
    required this.size,
    this.detail = 12, // 기본 12
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (shapeType) {
      case ShapeType.cube:
        return _buildCube();
      case ShapeType.sphere:
        return _buildSphere();
      case ShapeType.tetrahedron:
        return _buildTetrahedron();
      case ShapeType.cylinder:
        return _buildCylinder();
    }
  }

  // ---------------------------
  // 정육면체
  // ---------------------------
  Widget _buildCube() {
    return Stack(
      children: [
        // Front (z = +size/2)
        _face(
          color: Colors.red,
          translate: _Offset3D(0, 0, size / 2),
          rotateX: 0,
          rotateY: 0,
        ),
        // Back (z = -size/2)
        _face(
          color: Colors.green,
          translate: _Offset3D(0, 0, -size / 2),
          rotateX: math.pi,
          rotateY: 0,
        ),
        // Left (x = -size/2)
        _face(
          color: Colors.blue,
          translate: _Offset3D(-size / 2, 0, 0),
          rotateX: 0,
          rotateY: -math.pi / 2,
        ),
        // Right (x = +size/2)
        _face(
          color: Colors.yellow,
          translate: _Offset3D(size / 2, 0, 0),
          rotateX: 0,
          rotateY: math.pi / 2,
        ),
        // Top (y = -size/2)
        _face(
          color: Colors.purple,
          translate: _Offset3D(0, -size / 2, 0),
          rotateX: -math.pi / 2,
          rotateY: 0,
        ),
        // Bottom (y = +size/2)
        _face(
          color: Colors.orange,
          translate: _Offset3D(0, size / 2, 0),
          rotateX: math.pi / 2,
          rotateY: 0,
        ),
      ],
    );
  }

  // ---------------------------
  // 구 (다각형으로 근사)
  // ---------------------------
  Widget _buildSphere() {
    // 구를 detail(기본 12)개로 위아래를 쪼갠다고 생각해봐
    // 수직 방향으로 detail 등분, 수평 방향으로 detail 등분
    // 흔히 "uv sphere" 형태로 분할함
    List<Widget> polygons = [];

    // 각도 단위
    final dTheta = math.pi / detail;        // 세로(위->아래)
    final dPhi = 2 * math.pi / detail;      // 가로(원주)

    // 위도(i), 경도(j)
    for (int i = 0; i < detail; i++) {
      final theta1 = i * dTheta;
      final theta2 = (i + 1) * dTheta;

      for (int j = 0; j < detail; j++) {
        final phi1 = j * dPhi;
        final phi2 = (j + 1) * dPhi;

        // 구의 표면을 4각형(작은 사각형 패치)으로 잘라서 붙이자
        // 각 꼭지점 xyz를 구해
        final p1 = _sphereToXYZ(theta1, phi1, size / 2);
        final p2 = _sphereToXYZ(theta1, phi2, size / 2);
        final p3 = _sphereToXYZ(theta2, phi2, size / 2);
        final p4 = _sphereToXYZ(theta2, phi1, size / 2);

        // 사각형 한 면
        polygons.add(_polygonFace(
          [p1, p2, p3, p4],
          color: Color.lerp(Colors.blue, Colors.white, i / detail) ?? Colors.blue,
        ));
      }
    }

    return Stack(children: polygons);
  }

  // ---------------------------
  // 정사면체 (면 4개)
  // ---------------------------
  Widget _buildTetrahedron() {
    // 정사면체 좌표를 대충 만들어서 4면 붙이기
    // 한가지 방법: (1,1,1), (1,-1,-1), (-1,1,-1), (-1,-1,1)
    // -> 가운데가 (0,0,0)이 되도록 한 뒤, size로 스케일링
    final sqrt3 = math.sqrt(3);

    // 실제 정사면체를 더 예쁘게 하기 위해서, 아래는 간단히 표준 좌표 4개
    List<List<double>> vertices = [
      [1, 1, 1],
      [1, -1, -1],
      [-1, 1, -1],
      [-1, -1, 1],
    ];

    // 스케일링
    vertices = vertices.map((v) {
      return [v[0] * size / 2, v[1] * size / 2, v[2] * size / 2];
    }).toList();

    // 정사면체는 4개 면. 각 면은 꼭짓점 3개
    // 0,1,2
    // 0,1,3
    // 0,2,3
    // 1,2,3
    List<List<int>> faces = [
      [0, 1, 2],
      [0, 1, 3],
      [0, 2, 3],
      [1, 2, 3],
    ];

    // 색상 4개 정도
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
    ];

    List<Widget> widgets = [];
    for (int i = 0; i < faces.length; i++) {
      final f = faces[i];
      final p1 = vertices[f[0]];
      final p2 = vertices[f[1]];
      final p3 = vertices[f[2]];

      widgets.add(
        _polygonFace(
          [
            _Offset3D(p1[0], p1[1], p1[2]),
            _Offset3D(p2[0], p2[1], p2[2]),
            _Offset3D(p3[0], p3[1], p3[2]),
          ],
          color: colors[i],
        ),
      );
    }

    return Stack(children: widgets);
  }

  // ---------------------------
  // 원통 (상단/하단 원 + 측면을 다각형으로 근사)
  // ---------------------------
  Widget _buildCylinder() {
    // detail개의 면으로 측면을 근사
    // 위아래 각각 1개 원
    final double radius = size / 2;
    final double height = size; // 대충 높이 = size 로 설정

    List<Widget> polygons = [];

    // 1) 윗면
    polygons.add(
      _circleFace(
        radius: radius,
        yOffset: -height / 2,
        color: Colors.red,
        detail: detail,
        isTop: true,
      ),
    );

    // 2) 아랫면
    polygons.add(
      _circleFace(
        radius: radius,
        yOffset: height / 2,
        color: Colors.blue,
        detail: detail,
        isTop: false,
      ),
    );

    // 3) 측면 -> 높이가 size인 원통
    // 위아래원을 detail각형으로 쪼갰다고 생각하면, 동일한 i와 i+1을 연결
    final dTheta = 2 * math.pi / detail;
    for (int i = 0; i < detail; i++) {
      final theta1 = i * dTheta;
      final theta2 = (i + 1) * dTheta;

      // 윗원 (y = -height/2) 점 2개
      final top1 = _Offset3D(
        radius * math.cos(theta1),
        -height / 2,
        radius * math.sin(theta1),
      );
      final top2 = _Offset3D(
        radius * math.cos(theta2),
        -height / 2,
        radius * math.sin(theta2),
      );

      // 아랫원 (y = +height/2) 점 2개
      final bot1 = _Offset3D(
        radius * math.cos(theta1),
        height / 2,
        radius * math.sin(theta1),
      );
      final bot2 = _Offset3D(
        radius * math.cos(theta2),
        height / 2,
        radius * math.sin(theta2),
      );

      // 직사각형 한 면
      polygons.add(
        _polygonFace(
          [top1, top2, bot2, bot1],
          color: Colors.yellow.withOpacity(0.7),
        ),
      );
    }

    return Stack(children: polygons);
  }

  // ----------------------------------------------------------------
  // 아래는 면(폴리곤)을 그려주는 메서드들
  // ----------------------------------------------------------------

  /// 사각형/삼각형 등 다각형을 그리는 위젯
  Widget _polygonFace(
      List<_Offset3D> points, {
        required Color color,
      }) {
    // points를 2D로 투영해야 하는데,
    // Flutter의 Transform는 2D 매트릭스라서,
    // 일단 "Stack"에 각 면을 하나씩 배치 & 3D -> 2D transform 흉내 내는 꼼수.
    // 여기서는 "면 하나를 Transform으로"만 그려서,
    // 사실상 면의 모양도 ClipPath나 CustomPaint로 처리해야 해.

    // (간단화 버전) 면의 bounding box만 Container로 그리고, 안에 ClipPath로 polygon
    // 1) polygon의 모든 점들의 min/max x,y,z 구해서 bounding box 잡기
    final xs = points.map((p) => p.x).toList();
    final ys = points.map((p) => p.y).toList();
    final zs = points.map((p) => p.z).toList();

    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);

    // 중심점 구하기
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final centerZ = (zs.reduce(math.min) + zs.reduce(math.max)) / 2;

    // 면의 폭, 높이
    final width = (maxX - minX).abs();
    final height = (maxY - minY).abs();

    // 각 점을 bounding box 내부 좌표(0,0)~(width,height)로 매핑
    final localPoints = points.map((p) {
      return Offset(
        p.x - minX,
        p.y - minY,
      );
    }).toList();

    // Transform으로 3D 위치/회전 흉내내기
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
      // 1) 중심으로 이동
        ..translate(centerX, centerY, centerZ)
      // 여기서는 별도 회전이 없고, 좌표 자체를 3D로 만들어놨으니 pass
      // 2) 다시 -중심 bounding box 절반
        ..translate(-width / 2, -height / 2),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _PolygonPainter(
            localPoints: localPoints,
            color: color,
          ),
        ),
      ),
    );
  }

  /// 원(윗면/아랫면) 그리기
  Widget _circleFace({
    required double radius,
    required double yOffset,
    required Color color,
    required int detail,
    required bool isTop,
  }) {
    // detail각형으로 표현
    final dTheta = 2 * math.pi / detail;
    List<_Offset3D> circlePoints = [];
    for (int i = 0; i < detail; i++) {
      final theta = i * dTheta;
      circlePoints.add(_Offset3D(
        radius * math.cos(theta),
        yOffset,
        radius * math.sin(theta),
      ));
    }

    // 중앙점도 넣어야 면을 채우는 폴리곤(삼각형들)으로 만들 수 있음
    // isTop이면 다른 색, isBottom이면 다른 색...
    // 근데 간단히 한 번에 polygonFace로 하긴 어려워서,
    // 삼각형 detail개로 구성
    List<Widget> triangles = [];
    for (int i = 0; i < detail; i++) {
      final p1 = circlePoints[i];
      final p2 = circlePoints[(i + 1) % detail];
      final center = _Offset3D(0, yOffset, 0);
      triangles.add(
        _polygonFace([center, p1, p2], color: color),
      );
    }

    return Stack(children: triangles);
  }

  /// 구의 위도/경도(theta, phi)를 3D xyz로 변환
  _Offset3D _sphereToXYZ(double theta, double phi, double radius) {
    // theta: 0~π (위도), phi: 0~2π (경도)
    final x = radius * math.sin(theta) * math.cos(phi);
    final y = radius * math.cos(theta);
    final z = radius * math.sin(theta) * math.sin(phi);
    return _Offset3D(x, y, z);
  }

  /// 사각/삼각 면에 쓰는 단순 사각 Container
  Widget _face({
    required Color color,
    required _Offset3D translate,
    required double rotateX,
    required double rotateY,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(translate.x, translate.y, translate.z)
        ..rotateX(rotateX)
        ..rotateY(rotateY),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}

///
/// 2) Shape3DScreen
///    - 도형을 드래그로 옮기고, 회전 애니메이션 + 스페이스바 재생/정지,
///      도형 유형, 크기(detail) 등을 바꿀 수 있는 메인 화면
///
class Shape3DScreen extends StatefulWidget {
  @override
  _Shape3DScreenState createState() => _Shape3DScreenState();
}

class _Shape3DScreenState extends State<Shape3DScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;

  double _posX = 0;
  double _posY = 0;

  Offset _startDragPos = Offset.zero;
  Offset _startWidgetPos = Offset.zero;

  double _angleX = 0.0;
  double _angleY = 0.0;

  double _shapeSize = 100.0;
  ShapeType _selectedShape = ShapeType.cube;
  int _detail = 8; // 구나 원통 면을 얼마나 쪼갤지

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // 스페이스바 인식용

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          _togglePlayPause();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 도형 드래그 이동
              Positioned(
                left: _posX,
                top: _posY,
                child: GestureDetector(
                  onPanStart: (details) {
                    _startDragPos = details.globalPosition;
                    _startWidgetPos = Offset(_posX, _posY);
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      final dragDelta = details.globalPosition - _startDragPos;
                      _posX = _startWidgetPos.dx + dragDelta.dx;
                      _posY = _startWidgetPos.dy + dragDelta.dy;
                    });
                  },
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.transparent,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        if (_isPlaying) {
                          _angleX = _controller.value * 2 * math.pi;
                          _angleY = _controller.value * 2 * math.pi;
                        }
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateX(_angleX)
                            ..rotateY(_angleY),
                          child: Shape3DWidget(
                            shapeType: _selectedShape,
                            size: _shapeSize,
                            detail: _detail,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 재생/멈춤 버튼
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _togglePlayPause,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ),

              // 크기 조절 슬라이더
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Slider(
                  min: 50,
                  max: 200,
                  value: _shapeSize,
                  onChanged: (value) {
                    setState(() {
                      _shapeSize = value;
                    });
                  },
                ),
              ),

              // 디테일 조절 슬라이더 (구/원통 면 쪼개기)
              Positioned(
                bottom: 130,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Text("Detail"),
                    Expanded(
                      child: Slider(
                        min: 3,
                        max: 30,
                        divisions: 27,
                        value: _detail.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _detail = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text("$_detail"),
                  ],
                ),
              ),

              // 도형 선택 버튼들
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    _shapeButton(ShapeType.cube, 'Cube'),
                    SizedBox(width: 8),
                    _shapeButton(ShapeType.sphere, 'Sphere'),
                    SizedBox(width: 8),
                    _shapeButton(ShapeType.tetrahedron, 'Tetra'),
                    SizedBox(width: 8),
                    _shapeButton(ShapeType.cylinder, 'Cylinder'),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _shapeButton(ShapeType type, String label) {
    final isSelected = (type == _selectedShape);
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedShape = type;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }
}

///
/// 3) 폴리곤 그리기용 CustomPainter
///    - _polygonFace()가 내부에서 사용
///
class _PolygonPainter extends CustomPainter {
  final List<Offset> localPoints;
  final Color color;

  _PolygonPainter({
    required this.localPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(localPoints[0].dx, localPoints[0].dy);
    for (int i = 1; i < localPoints.length; i++) {
      path.lineTo(localPoints[i].dx, localPoints[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PolygonPainter oldDelegate) {
    return oldDelegate.localPoints != localPoints || oldDelegate.color != color;
  }
}

///
/// 4) 3D좌표 표현용
///
class _Offset3D {
  final double x;
  final double y;
  final double z;
  _Offset3D(this.x, this.y, this.z);
}


import { NODE_TITLE_HEIGHT } from '../utils/consts';
import React from 'react';
import { Rect, Text } from 'react-konva';
import { useNodeInfo } from '../hooks/useNodeInfo';
import { CodeckNodeComponentProps } from '../store/node';
import { useUIStore } from '../store/ui';
import { color } from '../utils/color';
import { BaseNodeWrapper } from './BaseNodeWrapper';
import { usePinRender } from './hooks/usePinRender';

export const BaseNode: React.FC<CodeckNodeComponentProps> = React.memo(
  (props) => {
    const nodeId = props.id;
    const { node, definition } = useNodeInfo(nodeId);
    const { selectedNodeIds } = useUIStore();
    const pinEl = usePinRender(nodeId);

    if (!node || !definition) {
      return null;
    }

    const { width, height, label } = definition;
    const { x, y } = node.position;

    return (
      <BaseNodeWrapper x={x} y={y} nodeId={nodeId}>
        <Rect
          width={width}
          height={height}
          opacity={0.8}
          cornerRadius={5}
          shadowColor="black"
          shadowBlur={10}
          shadowOpacity={0.5}
          stroke="white"
          strokeWidth={selectedNodeIds.includes(nodeId) ? 4 : 0}
          fillAfterStrokeEnabled={true}
          fillLinearGradientStartPoint={{ x: 0, y: 0 }}
          fillLinearGradientEndPoint={{ x: width, y: height }}
          fillLinearGradientColorStops={[
            0,
            color.nodeBoxGradient.start,
            1,
            color.nodeBoxGradient.end,
          ]}
        />

        <Rect
          width={width}
          height={NODE_TITLE_HEIGHT}
          fill={color.node[definition.type]}
          cornerRadius={[5, 5, 0, 0]}
        />

        <Text
          x={30}
          y={0}
          width={width - 30 * 2}
          height={NODE_TITLE_HEIGHT}
          align="left"
          verticalAlign="middle"
          fontSize={16}
          text={label}
          fill="white"
        />

        {pinEl}
      </BaseNodeWrapper>
    );
  }
);
BaseNode.displayName = 'BaseNode';

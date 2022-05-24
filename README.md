# Node2D-Context-Menu
Adds a Context Menu for Node2D nodes (and node types that extend Node2D) in the 2D editor.

To open the Context Menu, select a Node2D node and then right click anywhere in the 2D editor's viewport.

*Note: The root node of the scene must be of the "CanvasItem" base class (meaning Node2D and Control nodes, and any nodes that extend them) for the Context Menu to work.*


## Context Menu Features:
- Move selected node to mouse position
- Move selected node to mouse position with grid snapping
- Invert selected node's scale hosizontally
- Invert selected node's scale vertically
- Reset selected node's scale


## Credits & License
The credit for the original plugin, as well as most of this plugin's code, goes to [MightyPrinny](https://github.com/MightyPrinny) and their [Node 2D context menu for 2D scene editor](https://godotengine.org/asset-library/asset/596) plugin. As such, the original MIT license as it was created by them is still intact and in effect.

I started out by copying their project and then set to work, cleaning up the code, removing redundant code and features, improving the existing features and expanding upon its features by adding new ones. I also improved the outputs of the actions and created an error message that would tell the user how to use the plugin in the correct way in the event of them doing something wrong.

import osmnx as ox
import networkx as nx
import geopandas as gpd
import numpy as np
import matplotlib as mpl
# mpl.use('wxagg', force=True) 
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import matplotlib.patches as patches
from matplotlib.colors import ListedColormap
import shapely
from shapely import speedups
if speedups.available:
    speedups.enable()
import sec
from edge_assigment import assign_edges
import os

plt.ioff()

class Building():
    
    def __init__(self, point_coords=None, place_name=None, distance=1000):
        # gpd.geodataframe.GeoDataFrame.__init__(self)
        self.point_coords = point_coords
        self.place_name = place_name
        if self.point_coords:
            self.distance = distance
        self.is_downloaded = False
        self.is_merged = False
        self.nodes_assigned = False
        self.edges_assigned = False
        self.net_assigned = False

            

    def download_buildings(self):
        if self.point_coords:
            self.buildings = ox.footprints.footprints_from_point(self.point_coords, distance=self.distance)
            self.buildings = ox.project_gdf(self.buildings)
        else:
            self.buildings = ox.footprints.footprints_from_place(self.place_name)
            self.buildings = ox.project_gdf(self.buildings)
        self.is_downloaded = True
    
    def plot_buildings(self, fc='black', ec='gray', figsize=(10, 10), imgs_folder = ".temp", filename="buildings", file_format='png', dpi=300):
        if self.is_merged:
            raise Exception("merge_and_convex() already performed on Building. Please use plot_merged_buildings()")
        fig, ax = ox.plot_shape(self.buildings, fc=fc, ec=ec, figsize=figsize)
        ox.settings.imgs_folder = imgs_folder
        ox.save_and_show(fig, ax, save=True, show=False, close=True, filename=filename, file_format=file_format, dpi=dpi, axis_off=True)
        plt.close()
    
    def merge_and_convex(self, buffer=0.01):
        if self.is_merged:
            raise Exception("merge_and_convex() already performed on Building.")

        self.buildings = self.buildings.geometry.buffer(buffer)
        go = True
        length = len(self.buildings)
        i = 0
        print(i, length)
        while go:
            i += 1
            self.buildings = gpd.GeoDataFrame(geometry=list(self.buildings.unary_union)).convex_hull
            print(i, len(self.buildings))
            if len(self.buildings) == length:
                go = False
            else:
                length = len(self.buildings)
        self.is_merged = True
        self.buildings_df = gpd.GeoDataFrame(geometry=[build for build in self.buildings])

    def plot_merged_buildings(self, color='lightgray', edgecolor='black', figsize=(10, 10), imgs_folder = ".temp", filename="merged", file_format='png'):
        if not self.is_merged:
            raise Exception("Please run merge_and_convex() before.")
        self.buildings.plot(figsize=figsize, color=color, edgecolor=edgecolor)
        plt.axis('off')
        plt.tight_layout()
        os.makedirs(imgs_folder, exist_ok=True)
        plt.savefig(os.path.join(imgs_folder, filename + "." + file_format))
        plt.close()

    def assign_nodes(self):
        if not self.is_merged:
            raise Exception("Please run merge_and_convex() before.")
        self.nodes = self.buildings.centroid
        col = [1 for build in self.buildings] + [2 for node in self.nodes]
        self.nodes_df = gpd.GeoDataFrame(col, geometry=[build for build in self.buildings] + [node for node in self.nodes], columns=['color'])
        self.nodes_assigned = True

    def assign_edges_weights(self, distance_threshold=30):
        if not self.is_merged:
            raise Exception("Please run merge_and_convex() before.")
        self.edges, self.weights = assign_edges(self.buildings, distance_threshold=distance_threshold)

        nodes=self.nodes
        edges_segment = []
        for u, v in self.edges:
            node_u = nodes.iloc[u]
            node_v = nodes.iloc[v]
            edge_segment = shapely.geometry.LineString([list(node_u.coords)[0], list(node_v.coords)[0]])
            edges_segment.append(edge_segment)

        colors = [1 for build in self.buildings] + [2 for edge in edges_segment] + [3 for node in self.nodes]

        self.edges_df = gpd.GeoDataFrame(colors, geometry = [build for build in self.buildings] + edges_segment + 
                            [node for node in self.nodes], columns=['color'])
        self.edges_assigned = True
    
    def plot_nodes(self, figsize=(10, 10), colors=['lightgray', 'black'], markersize=0.1, imgs_folder = ".temp", filename="nodes", file_format='png'):
        cm = ListedColormap(colors, N=len(colors))
        plt.figure()
        self.nodes_df.plot(figsize=figsize, column='color', markersize=markersize, cmap=cm)
        plt.axis('off')
        plt.tight_layout()
        os.makedirs(imgs_folder, exist_ok=True)
        plt.savefig(os.path.join(imgs_folder, filename + "." + file_format))
        plt.close()

    def plot_edges(self, figsize=(10, 10), colors=['lightgray', 'black'], markersize=1, linewidth=0.5, imgs_folder = ".temp", filename="edges", file_format='png'):
        cm = ListedColormap(colors, N=len(colors))
        plt.figure()
        self.edges_df.plot(figsize=figsize, column='color', markersize=markersize, linewidth=linewidth, cmap=cm)
        plt.axis('off')
        plt.tight_layout()
        os.makedirs(imgs_folder, exist_ok=True)
        plt.savefig(os.path.join(imgs_folder, filename + "." + file_format))
        plt.close()

    def assign_network(self):
        G = nx.Graph()
        pos = {}
        for index, node in enumerate(self.nodes):
            G.add_node(index)
            pos[index] = list(node.coords)[0]
        for u, v in self.edges:
            G.add_edge(u, v)
            
        nx.set_edge_attributes(G, self.weights, name='weight')

        degrees_zero = []
        for node in G.nodes:
            k = nx.degree(G, node)
            if k == 0:
                degrees_zero.append(node)

        G.remove_nodes_from(degrees_zero)
        self.network = G        
        self.network_df = gpd.GeoDataFrame(geometry=[build for build in self.buildings])
        self.network_pos = pos
        self.net_assigned = True
        self.assign_node_color()

    def assign_node_color(self, colors = ['blue', 'cyan', 'greenyellow', 'yellow', 'orange', 'red']):
        G = self.network
        neigh_watch_sharp_dict = {}
        node_color = []
        for index, node in enumerate(G.nodes):
            k = nx.degree(G, node)
            w = nx.degree(G, node, weight='weight')
            nw = w / k
            
            if nw < 500:
                neigh_watch_sharp_dict[node] = 0
                node_color.append(colors[0])
            elif nw < 1000:
                neigh_watch_sharp_dict[node] = 1
                node_color.append(colors[1])
            elif nw < 1500:
                neigh_watch_sharp_dict[node] = 2
                node_color.append(colors[2])
            elif nw < 2000:
                neigh_watch_sharp_dict[node] = 3
                node_color.append(colors[3])
            elif nw < 2500:
                neigh_watch_sharp_dict[node] = 4
                node_color.append(colors[4])
            else:
                neigh_watch_sharp_dict[node] = 5
                node_color.append(colors[5])
        self.node_color = node_color
        self.neigh_watch_sharp_dict = neigh_watch_sharp_dict
        self.colors = colors

    def plot_net(self, figsize=(30, 30), imgs_folder = ".temp", filename="net", file_format='png'):
        
        G = self.network
        node_color = self.node_color
        
        weights_values = [self.weights[(u, v)] for u, v in G.edges]
        
        fig, ax  = plt.subplots(figsize=figsize)
        base = self.buildings_df.plot(ax=ax, color='gray', alpha=0.2)
        pos = self.network_pos
        nx.draw_networkx_nodes(G, pos=pos, with_labels=False, node_color=node_color, edgecolors='k', ax=ax)
        nx.draw_networkx_edges(G, pos=pos, width=[w * (2) ** (-8) for w in weights_values], ax=ax)
        plt.axis('off')
        plt.tight_layout()
        os.makedirs(imgs_folder, exist_ok=True)
        plt.savefig(os.path.join(imgs_folder, filename + "." + file_format))
        plt.close() 

    def plot_buildings_color(self, figsize=(30, 30), imgs_folder = ".temp", filename="buildings_color",
        file_format='png'):
            
            G = self.network
            node_color = self.node_color
            colors = self.colors
            neigh_watch_sharp_dict = self.neigh_watch_sharp_dict
            buildings_df = self.buildings_df

            cm = ListedColormap(colors, N=len(colors))
            buildings_df_colors = gpd.GeoDataFrame(columns=['geometry', 'nw_sharp'])
            for i, row in buildings_df.iterrows():
                if i in G.nodes:
                    nw_sharp = neigh_watch_sharp_dict[i]
                    geometry = row['geometry']
                    buildings_df_colors.loc[i] = [geometry, nw_sharp] 
            fig, ax = plt.subplots(figsize=figsize)
            base = buildings_df.plot(ax=ax, color='gray', alpha=0.2)
            buildings_df_colors.plot(ax=base, column='nw_sharp', cmap=cm, vmin=0,
                                vmax=5)
            buildings_df_colors.boundary.plot(ax=base, color='k')
            ax.axis('off')

            plt.tight_layout()
            plt.savefig(os.path.join(imgs_folder, filename + "." + file_format))
            plt.show()

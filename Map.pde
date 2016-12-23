/* 
 * Filename:    Map.pde
 * Author:      Rish Vaishnav
 * Date:        12/22/2016
 *
 * Description:
 * This file contains the map class. See class header for more
 * information.
 */

/**
 * This class represents a Map with various locations and paths beween
 * locations that can be drawn.
 */
class Map 
{
    /* the locations of this map */
    Location[] locs;

    /* the paths of this map, as represented in a 2D array of paths between
     * locations with different indices */
    Path[][] paths;

    /* is this map currently animating ACO? */
    boolean animating_ACO = false;

    /** 
     * Initializes this map with the specified Locations, and automatically
     * constructs all paths between these locations.
     *
     * @param init_locs the locations to use in the map
     */
    public Map ( Location[] init_locs )
    {
        /* set the locations */
        this.setLocs( init_locs );
    }

    /**
     * Sets the locations used in this map.
     *
     * @param new_locs the locations in this map
     */
    public void setLocs ( Location[] new_locs )
    {
        this.locs = new_locs;

        /* set the paths */
        this.setPaths( this.getAllPaths( this.getLocs() ) );
    }
    
    /**
     * Returns the locations used in this map.
     *
     * @return the locations in this map
     */
    public Location[] getLocs ()
    {
        return this.locs;
    }

    /**
     * Sets the paths on this map.
     *
     * @param new_paths the paths on this map
     */
    public void setPaths ( Path[][] new_paths )
    {
        this.paths = new_paths;
    }

    /**
     * Returns the paths on this map.
     *
     * @return the paths on this map
     */
    public Path[][] getPaths ()
    {
        return this.paths;
    }

    /**
     * Returns a 2D array of paths that represent the set of all paths between
     * all of the locations in a given set of locations.
     *
     * @param locs the locs to use to construct the paths
     */
    public Path[][] getAllPaths ( Location[] locs )
    {
        /* to store the paths to return */
        Path[][] paths = new Path[ locs.length ][ locs.length ];

        /* go through each of the rows in paths */
        for ( int row = 0; row < paths.length; row++ )
        {
            /* go through each of the columns in paths */
            for ( int col = 0; col < paths.length; col++ )
            {
                /* the row is not equal to the column, so a path is defined
                 * between the two locations because they are not the same
                 * locations */
                if ( row != col )
                {
                    /* construct the path from the location at index row to the
                     * location at index col */
                    paths[ row ][ col ] = paths[ col ][ row ]
                        = new Path( locs[ row ], locs[ col ] );
                }
            }
        }

        return paths;
    }

    /**
     * Update the graphical representation of this map.
     */
    public void update ()
    {
        /* this map is currently animating ACO, so send out a pack of ants */
        /* continue sending ants until stagnating state is reached */
        if ( animating_ACO )
        {
            /* reset ant arrays */

            /* reset - has this ant visited this location already? */
            for ( int i = 0; i < ant_visited_loc.length; i++ )
            {
                for ( int j = 0; j < ant_visited_loc[ i ].length; j++ )
                {
                    ant_visited_loc[ i ][ j ] = false;
                }
            }

            /* reset - the indices of the locations in the tour this ant has
             * construced */
            for ( int i = 0; i < ant_tour_inds.length; i++ )
            {
                for ( int j = 0; j < ant_tour_inds[ i ].length; j++ )
                {
                    ant_tour_inds[ i ][ j ] = -1;
                }
            }

            /* go through each of the ants in an iteration */
            for ( int ant = 0; ant < m; ant++ )
            {
                /* the index of the tour the ant is currently on */
                int tour_ind = 0;

                /* the index of the starting location of this ant */ 
                int start_loc_ind = ( int ) ( Math.random() * locs.length );

                /* the current location of the ant */
                int curr_loc_ind = start_loc_ind;

                /* add the start location to the tour */
                ant_tour_inds[ ant ][ tour_ind ] = start_loc_ind;
                /* go to the next index */
                tour_ind++;

                /* the start location has been visited */
                ant_visited_loc[ ant ][ start_loc_ind ] = true;

                /* the number of unvisited paths */
                int num_unvisited = n - 1;

                /* continue until all locations have been visited */
                while( num_unvisited > 0 )
                {
                    /* the total value of the remaining path weights */
                    double total_weight = 0;

                    /* the number of NaNs found */
                    int num_NaNs = 0;
     
                    /* go through each of the locations */
                    for ( int locs_i = 0; locs_i < locs.length; locs_i++ )
                    {
                        /* the ant has not already visited this location */
                        if ( !ant_visited_loc[ ant ][ locs_i ] )
                        {
                            /* add the weight of this path to the total */
                            total_weight
                                += paths[ curr_loc_ind ][ locs_i ].getWeight( 
                                alpha, beta );
                        }
                    }

                    /* go through each of the locations */
                    for ( int locs_i = 0; locs_i < locs.length; locs_i++ )
                    {
                        /* the ant has not already visited this location */
                        if ( !ant_visited_loc[ ant ][ locs_i ] )
                        {
                            /* set the probability of the ant choosing this
                             * path */
                            probs[ locs_i ] =
                                paths[ curr_loc_ind ][ locs_i ].getWeight( 
                                alpha, beta ) / total_weight;

                            /* this probability is very, very small */
                            if ( Double.isNaN( probs[ locs_i ] ) )
                            {
                                /* there is one more NaN */
                                num_NaNs++;
                            }
                        }
                        /* the ant has already visited this location */
                        else
                        {
                            /* set the probability of the ant choosing this
                             * path to 0, because the ant has already been
                             * here */
                            probs[ locs_i ] = 0;
                        }
                    }

                    /* the weight is so small that it is essentially 0 */
                    if ( total_weight == 0.0 )
                    {
                        /* go through each of the locations */
                        for ( int locs_i = 0; locs_i < locs.length; locs_i++ )
                        {
                            /* the ant has not already visited this location */
                            if ( !ant_visited_loc[ ant ][ locs_i ] )
                            {
                                /* set the probability of the ant choosing this
                                 * path to the same for every possible end
                                 * location */
                                probs[ locs_i ] = 1.0 / ( double ) num_NaNs;
                            }
                        }
                    }

                    EnumeratedIntegerDistribution path_dist = null;
     
                    /* this may not work */
                    try
                    {
                        /* create a new enumerated random distribution using
                         * the paths and the path probabilites to determine the
                         * path the ant takes next */
                        path_dist = 
                            new EnumeratedIntegerDistribution( 
                            locs_inds, probs );
                    }
                    catch ( Exception e )
                    {
                        e.printStackTrace();
                        System.out.println( Arrays.toString( probs ) );
                    }

                
                    /* choose a location to move to from the distribution */
                    int chosen_loc_ind = path_dist.sample();

                    /* the current location of the ant */
                    curr_loc_ind = chosen_loc_ind;

                    /* add the chosen location to the tour */
                    ant_tour_inds[ ant ][ tour_ind ] = curr_loc_ind;

                    /* go to the next index in the tour */
                    tour_ind++;

                    /* the chosedn location has been visited */
                    ant_visited_loc[ ant ][ curr_loc_ind ] = true;

                    /* one more location has been visited */
                    num_unvisited--;
                }
            }

            /* go through each of the rows in paths */
            for ( int row = 0; row < paths.length; row++ )
            {
                /* go through each of the columns in paths that are greater
                 * than the row */
                for ( int col = row + 1; col < paths[ row ].length; col++ )
                {
                    /* evaporate the pheromone along this path */
                    paths[ row ][ col ].evaporatePheromone();
                }
            }

            /* go through all ants  */
            for ( int ant = 0; ant < m; ant++ )
            {
                /* the length of this ant's tour */
                double this_ant_tour_length = TSPAlgorithms.get_tour_length( 
                    TSPAlgorithms.get_tour_from_inds( locs, 
                    ant_tour_inds[ ant ] ) );

                /* go through all paths in this ant's tour */
                for ( Path path : 
                    TSPAlgorithms.get_all_paths_in_tour( paths, 
                    ant_tour_inds[ ant ] ) )
                {
                    /* add pheromone to this path */
                    path.addPheromone( 1 / this_ant_tour_length );
                }
            }
        }

        /* go through all of the paths */
        for ( int row = 0; row < this.getPaths().length; row++ )
        {
            for ( int col = row + 1; col < this.getPaths()[ row ].length;
                col++ )
            {
                /* update this path */
                this.getPaths()[ row ][ col ].update();
            }
        }

        /* go through all of the locations */
        for ( Location loc : this.getLocs() )
        {
            /* update this location */
            loc.update();
        }
    }

    /* the number of locations */
    private int n;

    /* the length of a tour constructed by the nearest neighbor solution */
    private double C_nn;

    /* the number of ants to send out in one iteration */
    private int m;

    /* has this ant visited this location already? */
    private boolean[][] ant_visited_loc;

    /* the indices of the locations in the tour this ant has constructed */
    private int[][] ant_tour_inds;

    /* solution tour inds */
    /* initialize first ant's tour to pass compilation */
    private int[] sol_tour_inds;

    /* the weight to give pheromone */
    private double alpha;
    /* the weight to give length */
    private double beta;

    /* to store the indices of the end locations of each path */
    private int[] locs_inds;

    /* to store the probabilities of each path to other
     * locations from the given location */
    private double[] probs;

    /**
     * Begin this map animating ACO.
     */
    public void animateACO ()
    {
        /* this map is now animating ACO */
        animating_ACO = true;

        /* the number of locations */
        n = this.getLocs().length;

        /* the length of a tour constructed by the nearest neighbor solution */
        C_nn = TSPAlgorithms.get_tour_length( 
            TSPAlgorithms.sol_greedy( locs ) );

        /* the number of ants to send out in one iteration */
        m = n;

        /* go through each of the rows in paths */
        for ( int row = 0; row < paths.length; row++ )
        {
            /* go through each of the columns in paths */
            for ( int col = 0; col < paths.length; col++ )
            {
                /* the row is less than to the column, so this will not
                 * be entered twice for the same path */
                if ( row < col )
                {
                    /* initialize the pheromone along this path */
                    paths[ row ][ col ].setPheromone( 
                        m / C_nn );
                }
            }
        }

        /* has this ant visited this location already? */
        ant_visited_loc = new boolean[ m ][ n ];

        /* the indices of the locations in the tour this ant has constructed */
        ant_tour_inds = new int[ m ][ n ];

        /* solution tour inds */
        /* initialize first ant's tour to pass compilation */
        sol_tour_inds = new int[ locs.length ];

        /* the weight to give pheromone */
        alpha = 1;
        /* the weight to give length */
        beta = 4;

        /* to store the indices of the end locations of each path */
        locs_inds = new int[ locs.length ];

        /* set locs_inds */
        for ( int i = 0; i < locs_inds.length; i++ )
        {
            locs_inds[ i ] = i;
        }

        /* to store the probabilities of each path to other
         * locations from the given location */
        probs = new double[ locs.length ];
    }
}
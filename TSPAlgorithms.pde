/* 
 * Filename:    TSPAlgorithms.pde
 * Author:      Rish Vaishnav
 * Date:        12/22/2016
 *
 * Description:
 * This file contains the TSPAlgorithms class. See class header for more 
 * information.
 */
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import org.apache.commons.math3.distribution.EnumeratedIntegerDistribution;

/**
 * This class is a utility class that contains various methods that can be used
 * to find solutions to the Traveling Salesman Problem (TSP); See method
 * headers for more information.
 */
public static class TSPAlgorithms
{
    /* is debug mode on? */
    public static final boolean DEBUG = false;

    /* the x- and y-coordinates of the origin */
    public static final double ORIGIN_X = 20;
    public static final double ORIGIN_Y = 20;

    /**
     * This method uses the greedy algorithm to find an (often unoptimal) 
     * solution the TSP. That is, it seeks a shortest-lenth Hamiltonian circuit
     * through a given set of locations by starting at a certain location,
     * moving to the nearest location, and continuing to do so until all of the
     * locations have been visited. This is done using each of the given
     * locations as a starting location. After determining which starting
     * location produces the minimum-length tour, the greedy algorithm tour
     * corresponding to this location is returned (represented as an ordered
     * array of locations). This tour can be reversed and/or rotated to
     * produce other tours of equivalent length.
     *
     * @param locs the locations to use to find a solution
     *
     * @return an array representing the minimum-length Hamiltonian tour
     * through the graph, as determined using the greedy algorithm
     */
    public static Location[] sol_greedy ( Location[] locs )
    {
        /* minimum tour length so far */
        double min_length = Double.MAX_VALUE;
        
        /* minimum length tour so far */
        Location[] min_length_tour = null;

        /* iterate through every location */
        for ( int locs_i = 0; locs_i < locs.length; locs_i++ )
        {
            /* get at greedy tour starting at this location */
            Location[] this_tour = get_greedy_start( locs, locs_i );
            /* get the length of this tour */
            double this_tour_length = get_tour_length( this_tour );

            /* this tour's length is less than the minimum length so far */
            if ( this_tour_length < min_length )
            {
                /* reset the minimum length */
                min_length = this_tour_length;

                /* reset the minimum length tour */
                min_length_tour = this_tour;
            }
        }

        /* return the minimum length greedy tour */
        return min_length_tour;
    }

    /** 
     * This method uses the greedy algorithm to find an (often unoptimal)
     * solution the TSP, starting at a specified location. That is, it seeks a
     * shortest-lenth Hamiltonian tour through a given set of locations by
     * starting at a certain location, moving to the nearest location, and
     * continuing to do so until all of the locations have been visited.  This
     * tour can be reversed and/or rotated to produce other tours of equivalent
     * length.
     *
     * @param locs the locations to use to find a solution
     * @param start_ind the index of the locations at which to start the greedy
     * algorithm
     *
     * @return an array representing the minimum-length Hamiltonian tour
     * through the graph, as determined using the greedy algorithm starting at
     * the location with index start_ind
     */
    public static Location[] get_greedy_start( Location[] locs, int start_ind )
    {
        /* has the location at this index been visited? */
        boolean[] loc_visited = new boolean[ locs.length ];

        /* the number of locations visited */
        int locs_visited = 0;

        /* initialize the current location and the greedy tour with the
         * location at start_ind */
        Location current_loc = locs[ start_ind ];
        Location[] greedy_tour = new Location[ locs.length ];
        int greedy_tour_ind = 0;
        greedy_tour[ greedy_tour_ind ] = locs[ start_ind ];
        greedy_tour_ind++;

        /* remove this location from the remaining locations */
        loc_visited[ start_ind ] = true;
        locs_visited++;

        /* continue until there are no remaining locations */
        while ( locs_visited != locs.length )
        {
            /* minimum distance to a location so far */
            double min_dist = Double.MAX_VALUE;
            Location min_dist_loc = null;
            int min_dist_loc_ind = -1;

            /* go through loc_visited */
            for ( int i = 0; i < loc_visited.length; i++ )
            {
                /* this location has not been visited */
                if ( !loc_visited[ i ] )
                {
                    /* get the distance to this location */
                    double this_dist = get_distance_between( current_loc, 
                        locs[ i ] );

                    /* this distance is less than the minimum distance so 
                     * far */
                    if ( this_dist < min_dist )
                    {
                        /* this is the new minimum distance location */
                        min_dist = this_dist;
                        min_dist_loc = locs[ i ];
                        min_dist_loc_ind = i;
                    }
                }
            }
            /* add this location to the greedy tour */
            greedy_tour[ greedy_tour_ind ] = min_dist_loc;
            greedy_tour_ind++;
            /* remove this location from the remaining locations */
            loc_visited[ min_dist_loc_ind ] = true;
            locs_visited++;
            /* this is the new current loc */
            current_loc = min_dist_loc;
        }

        /* return the greedy tour */
        return greedy_tour;
    }

    /**
     * Helper method that returns the index of the first element in a boolean
     * that is false.
     *
     * @param arr the array to check
     *
     * @return the index of the first element in a boolean that is false, or
     * -1 if every element is true
     */
    public static int get_first_false_ind ( boolean[] arr )
    {
        /* go through the entire array */
        for ( int arr_i = 0; arr_i < arr.length; arr_i++ )
        {
            /* the element at this index is true */
            if ( arr[ arr_i ] == true )
            {
                return arr_i;
            }
        }

        /* no element was found */
        return -1;
    }

    /* the number of times the simple ACO algorithm has to produce the same
     * tour for a given ant in a row to declare that the algorithm has
     * stagnated */
    private static final int STAGNATION_THRESHHOLD = 10;

    /**
     * This method uses a basic version of the Ant Colony Optimization (also
     * known as Ant System, "AS") algorithm to find a solution the TSP. That
     * is, it seeks a shortest-length Hamiltonian circuit through a given set
     * of locations by starting a virtual ant at a certain location, and
     * choosing and moving to a location from among the remaining locations
     * based on a probability that depends on the amount of virtual "pheromone"
     * on that edge. As the ant moves along the edge, it lays down its own
     * pheromone, and the pheromone along all of the edges evaporates by some
     * proportion. This repeauts until an ant completes a hamiltonian circuit,
     * after which another ant is sent out to repeat the process. This is
     * continued until the ants reach a stagnating state - that is, when
     * subsequent ants all construct the same circuit a specified number of
     * times.
     *
     * @param locs the locations to use to find a solution
     *
     * @return an array representing the minimum-length Hamiltonian tour
     * through the graph, as determined using the simple ACO algorithm
     */
    public static Location[] sol_ACO_AS ( Map map )
    {
        /* the locations of this map */
        Location[] locs = map.getLocs();

        /* the number of locations */
        int n = locs.length;

        /* the length of a tour constructed by the nearest neighbor solution */
        double C_nn = get_tour_length( sol_greedy( locs ) );

        /* the number of ants to send out in one iteration */
        int m = n;

        /* get all of the paths involving locs */
        Path[][] paths = map.getPaths();


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
        boolean[][] ant_visited_loc = new boolean[ m ][ n ];

        /* the indices of the locations in the tour this ant has constructed */
        int[][] ant_tour_inds = new int[ m ][ n ];

        /* solution tour inds */
        /* initialize first ant's tour to pass compilation */
        int[] sol_tour_inds = new int[ locs.length ];

        /* the weight to give pheromone */
        double alpha = 1;
        /* the weight to give length */
        double beta = 4;

        /* TODO remove TODO */
        int num_iterations = 10000;

        /* has a stagnating state been reached? */
        boolean stagnated = false;

        /* to store the indices of the end locations of each path */
        int[] locs_inds = new int[ locs.length ];

        /* set locs_inds */
        for ( int i = 0; i < locs_inds.length; i++ )
        {
            locs_inds[ i ] = i;
        }

        /* to store the probabilities of each path to other
         * locations from the given location */
        double[] probs = new double[ locs.length ];

        /* continue sending ants until stagnating state is reached */
        while ( !stagnated )
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
                double this_ant_tour_length = get_tour_length( 
                    get_tour_from_inds( locs, ant_tour_inds[ ant ] ) );

                /* go through all paths in this ant's tour */
                for ( Path path : 
                    get_all_paths_in_tour( paths, ant_tour_inds[ ant ] ) )
                {
                    /* add pheromone to this path */
                    path.addPheromone( 1 / this_ant_tour_length );
                }
            }

            /* update the map */
            map.update();

            /* TODO replace with stagnation check */
            if ( num_iterations <= 0 )
            {
                stagnated = true;
            }

            if ( DEBUG && stagnated )
            {
                System.out.println( "Ant Tours Constructed:" );
                for ( int i = 0; i < m; i++ )
                {
                    System.out.print( "Ant " + i + ": " );
                    int j = 0;
                    for ( j = 0; j < ant_tour_inds[ i ].length - 1; j++ )
                    {
                        System.out.print( ant_tour_inds[ i ][ j ] + ", " );
                    }
                    System.out.print( ant_tour_inds[ i ][ j ] );
                    System.out.print( " (" + get_tour_length( 
                        get_tour_from_inds( locs, ant_tour_inds[ i ] ) ) + ")" );
                    System.out.println();
                }

                System.out.println( "Pheromone Values (x1000):" );

                System.out.print( "  " );
                /* go through each of the columns in paths */
                for ( int col = 0; col < paths[ 0 ].length; col++ )
                {
                    System.out.print( col + "    " );
                }
                System.out.println();
                /* go through each of the rows in paths */
                for ( int row = 0; row < paths.length; row++ )
                {
                    int col = 0;
                    System.out.print( row + " " );
                    /* go through each of the columns in paths */
                    for ( col = 0; col < paths[ row ].length; col++ )
                    {
                        /* there is a path defined here */
                        if ( row != col )
                        {
                            System.out.printf( "%.2f ", 
                                ( paths[ row ][ col ].getPheromone() * 1000 ) );
                        }
                        else 
                        {
                            System.out.print( "0.00 " );
                        }
                    }
                    System.out.println();
                }
            }

            num_iterations--;
            /**/
        }
        
        /* the minimum tour distance so far */
        double min_tour_dist = Double.MAX_VALUE;

        /* go through all of the ants */
        for ( int ant = 0; ant < m; ant++ )
        {
            /* the length of this ant's tour */
            double this_dist = get_tour_length( get_tour_from_inds( 
                locs, ant_tour_inds[ ant ] ) );

            /* this distance is less than the minimum so far */
            if ( this_dist < min_tour_dist )
            {
                /* reset the minimum and the solution */
                min_tour_dist = this_dist;
                sol_tour_inds = ant_tour_inds[ ant ];
            }
        }

        /* return the ant's tour with minimum distance */
        return get_tour_from_inds( locs, sol_tour_inds );
    }

    /**
     * This method uses a the min-max version of the Ant Colony Optimization
     * algorithm to find a solution the TSP. This min-max ant system (MMAS)
     * differs from the basic implementation in that the amount of pheromone on
     * an edge is limited by minimum and maximum values, and the initial amount
     * of pheromone on each path is determined by the length of the solution as
     * determined by the greedy algorithm.
     *
     * @param locs the locations to use to find a solution
     *
     * @return an array representing the minimum-length Hamiltonian tour
     * through the graph, as determined using the simple ACO algorithm
     */
    public static Location[] sol_ACO_MMAS ( Location[] locs )
    {
        /* TODO */
        return null;
        /**/
    }

    /**
     * Returns the distance between two given locations.
     *
     * @param loc1 the first location
     * @param loc2 the second location
     *
     * @return the distance between loc1 and loc2
     */
    public static double get_distance_between ( Location loc1, Location loc2 )
    {
        /* the x- and y-distances between the two locations */
        double x_dis = loc1.getX() - loc2.getX();
        double y_dis = loc1.getY() - loc2.getY();

        /* return the distance between loc1 and loc2 */
        return Math.sqrt( Math.pow( x_dis, 2 ) + Math.pow( y_dis, 2 ) );
    }

    /**
     * Returns a tour, given an array of locations and another array containig
     * the order of the indices from the array of location with which to
     * construct the tour.
     *
     * @param locs the locations
     * @param inds the indices
     *
     * @return a tour, given an array of locations and another array containig
     * the order of the indices from the array of location with which to
     * construct the tour
     */
    public static Location[] get_tour_from_inds( Location[] locs, int[] inds )
    {
        /* the tour to return */
        Location[] tour = new Location[ locs.length ];

        /* go through all of the indices */
        for ( int inds_i = 0; inds_i < inds.length; inds_i++ )
        {
            /* set this location in the tour */
            tour[ inds_i ] = locs[ inds[ inds_i ] ];
        }

        return tour;
    }

    /**
     * Returns an array of paths containing each path taken by an ant going on
     * a given tour.
     *
     * @param paths all of the possible paths
     * @param tour_inds the indices of the locations in the ant's tour
     *
     * @return an array of paths containing each path taken by an ant going on
     * a given tour
     */
    public static Path[] get_all_paths_in_tour ( Path[][] paths, int[] tour_inds )
    {
        /* the paths taken by the ant in the tour */
        Path[] paths_taken = new Path[ tour_inds.length ];

        /* the index in tour_inds */
        int tour_inds_i = 0;

        /* go through all of tour_inds */
        for ( tour_inds_i = 0; tour_inds_i < tour_inds.length - 1;
             tour_inds_i++ )
        {
            /* this path is the path from this location index to the next in
             * tour_inds */
            paths_taken[ tour_inds_i ]
                = paths[ tour_inds[ tour_inds_i ] ]
                [ tour_inds[ tour_inds_i + 1 ] ];
        }
        /* include the path from the last index in tour_inds to the first to
         * account for completing the cycle */
        paths_taken[ tour_inds_i ]
            = paths[ tour_inds[ tour_inds_i ] ] [ tour_inds[ 0 ] ];

        /* return the paths taken */
        return paths_taken;
    }

    /**
     * Returns the total length of a given tour, including the distance from
     * the last location to the first location.
     *
     * @param tour the tour to find the length of
     *
     * @return the total length of the tour
     */
    public static double get_tour_length ( Location[] tour )
    {
        /* the total length of the tour */
        double total = 0.0;

        /* go through each location except the last one */
        for ( int tour_i = 0; tour_i < tour.length - 1; tour_i++ )
        {
            /* add the distance between this location and the next to the total
             * length of the tour so far */
            total += get_distance_between( tour[ tour_i ], tour[ tour_i + 1 ] );
        }
        /* add the distance between the last location and the first to the total
         * length of the tour */
        total += get_distance_between( tour[ tour.length - 1 ], tour[ 0 ] );

        /* return the total length of the tour */
        return total;
    }
}

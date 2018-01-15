require 'search_worker'
require 'web_worker'

class FetchController < ApplicationController

  def query
    worker = SearchWorker.new
    worker.search(params)
    sleep(1)

    worker.get_results.each_with_index do |term, i|
      search_term = "#{term[:company]} #{term[:city]} #{term[:state]}"
      spawn_worker(search_term, i)
    end

    worker.done
    render "process_list"
  end

  def process_list
    list = params[:targets].split(/\r/)
    list.map! {|x| x.lstrip}
    list.each_with_index {|x, i| spawn_worker(x, i)}
  end

  def check_queue_status
    @list = get_result
    unless @list.empty?
      @list.each {|x| log_result(x)}
      render :layout => false
    else
      render :nothing => true
    end
  end

  def export

    data = []

    params[:markup].each do |row|
      t = row.split />/ 
      rdata = [t[6], t[9], t[12], t[14]]
      rdata.map! {|x| x.gsub /<.*$/, ''}
      data << rdata.join(',')
    end

    send_data data.join("\n"), :type => "text/csv"
  end

private

  def spawn_worker(terms, position)
    Spawnling.new(:method => :fork) do
      with_beanstalk do |queue|
        worker = WebWorker.new(terms, position)
        queue.put Marshal.dump(worker) 
      end
    end
  end

  def get_result
    rval = []
    with_beanstalk do |queue|
      while queue.peek(:ready)
        job = queue.reserve
        rval << Marshal.load(job.body)
        job.delete
      end
    end

    rval
  end

  def with_beanstalk
    conn = Beaneater::Pool.new(['localhost:11300'])
    queue = conn.tubes["tube"]
    yield queue
    conn.close
  end

  def log_result(w)
    logger.debug("RESULT #{w.query} #{w.url} #{w.framework} #{w.analytics}")
  end
end 
